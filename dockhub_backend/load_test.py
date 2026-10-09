import asyncio
import time
import statistics
import json
import sys
import aiohttp
from typing import List, Dict, Any

TARGET_URL = "http://localhost:8000"
CONCURRENCY = 100
DURATION_SECONDS = 60

ENDPOINTS = [
    {"path": "/", "weight": 30, "method": "GET"},
    {"path": "/dashboard_stats", "weight": 30, "method": "GET"},
    {"path": "/history?user_email=admin@dockhub.bio", "weight": 20, "method": "GET"},
    {"path": "/saved_results?user_email=admin@dockhub.bio", "weight": 20, "method": "GET"},
]

class LoadTester:
    def __init__(self, target_url: str, concurrency: int, duration: int):
        self.target_url = target_url.rstrip("/")
        self.concurrency = concurrency
        self.duration = duration
        self.results: List[Dict[str, Any]] = []
        self.start_time = 0.0
        self.end_time = 0.0
        self.total_requests = 0
        self.successful_requests = 0
        self.failed_requests = 0

    async def worker(self, worker_id: int, session: aiohttp.ClientSession, end_timestamp: float):
        import random
        endpoint_choices = []
        for ep in ENDPOINTS:
            endpoint_choices.extend([ep] * ep["weight"])

        while time.time() < end_timestamp:
            ep = random.choice(endpoint_choices)
            url = f"{self.target_url}{ep['path']}"
            req_start = time.perf_counter()
            status = 0
            error = None
            try:
                async with session.request(ep["method"], url, timeout=aiohttp.ClientTimeout(total=5.0)) as resp:
                    status = resp.status
                    await resp.read()
                    req_end = time.perf_counter()
                    latency_ms = (req_end - req_start) * 1000.0
                    is_success = (200 <= status < 300)
            except Exception as e:
                req_end = time.perf_counter()
                latency_ms = (req_end - req_start) * 1000.0
                is_success = False
                error = str(e)

            self.results.append({
                "worker_id": worker_id,
                "endpoint": ep["path"],
                "status": status,
                "latency_ms": latency_ms,
                "success": is_success,
                "error": error
            })
            # Realistic user request think time (15-40ms between API actions)
            await asyncio.sleep(random.uniform(0.015, 0.040))

    async def run(self):
        print(f"================================================================")
        print(f" Starting Baseline / Load Test against {self.target_url}")
        print(f" Virtual Users (Concurrency): {self.concurrency}")
        print(f" Duration: {self.duration} seconds")
        print(f"================================================================")

        connector = aiohttp.TCPConnector(limit=200, limit_per_host=150, ttl_dns_cache=300)
        async with aiohttp.ClientSession(connector=connector) as session:
            self.start_time = time.time()
            end_timestamp = self.start_time + self.duration
            workers = [
                asyncio.create_task(self.worker(i, session, end_timestamp))
                for i in range(self.concurrency)
            ]
            
            # Progress tracker loop
            while time.time() < end_timestamp:
                elapsed = time.time() - self.start_time
                completed = len(self.results)
                rps = completed / elapsed if elapsed > 0 else 0
                print(f"\rProgress: [{elapsed:.1f}s / {self.duration}s] | Total Requests: {completed} | Current RPS: {rps:.1f} req/s", end="", flush=True)
                await asyncio.sleep(1.0)

            await asyncio.gather(*workers, return_exceptions=True)
            self.end_time = time.time()

        print("\n\nLoad test completed! Analyzing results...\n")
        return self.generate_report()

    def generate_report(self) -> Dict[str, Any]:
        total_time = self.end_time - self.start_time
        total_reqs = len(self.results)
        successful = [r for r in self.results if r["success"]]
        failed = [r for r in self.results if not r["success"]]
        latencies = [r["latency_ms"] for r in self.results]
        success_latencies = [r["latency_ms"] for r in successful]

        rps = total_reqs / total_time if total_time > 0 else 0
        success_rate = (len(successful) / total_reqs * 100.0) if total_reqs > 0 else 0.0
        failure_rate = (len(failed) / total_reqs * 100.0) if total_reqs > 0 else 0.0

        if latencies:
            latencies_sorted = sorted(latencies)
            min_lat = min(latencies)
            max_lat = max(latencies)
            avg_lat = statistics.mean(latencies)
            median_lat = statistics.median(latencies)
            p90_idx = int(len(latencies_sorted) * 0.90)
            p95_idx = int(len(latencies_sorted) * 0.95)
            p99_idx = int(len(latencies_sorted) * 0.99)
            p90_lat = latencies_sorted[min(p90_idx, len(latencies_sorted)-1)]
            p95_lat = latencies_sorted[min(p95_idx, len(latencies_sorted)-1)]
            p99_lat = latencies_sorted[min(p99_idx, len(latencies_sorted)-1)]
        else:
            min_lat = max_lat = avg_lat = median_lat = p90_lat = p95_lat = p99_lat = 0.0

        report = {
            "target_url": self.target_url,
            "virtual_users": self.concurrency,
            "duration_seconds": round(total_time, 2),
            "total_requests": total_reqs,
            "successful_requests": len(successful),
            "failed_requests": len(failed),
            "requests_per_second_rps": round(rps, 2),
            "success_rate_pct": round(success_rate, 2),
            "failure_rate_pct": round(failure_rate, 2),
            "response_time_ms": {
                "min": round(min_lat, 2),
                "avg": round(avg_lat, 2),
                "median_p50": round(median_lat, 2),
                "p90": round(p90_lat, 2),
                "p95": round(p95_lat, 2),
                "p99": round(p99_lat, 2),
                "max": round(max_lat, 2)
            }
        }

        print("================================================================")
        print("                 LOAD TEST SUMMARY RESULTS                      ")
        print("================================================================")
        print(f" Target Endpoint         : {report['target_url']}")
        print(f" Concurrent Virtual Users: {report['virtual_users']}")
        print(f" Test Duration           : {report['duration_seconds']}s")
        print(f" Total Requests Sent     : {report['total_requests']:,}")
        print(f" Successful Requests     : {report['successful_requests']:,} ({report['success_rate_pct']}%)")
        print(f" Failed Requests         : {report['failed_requests']:,} ({report['failure_rate_pct']}%)")
        print(f" Requests Per Sec (RPS)  : {report['requests_per_second_rps']:,} req/sec")
        print("----------------------------------------------------------------")
        print(" RESPONSE TIMES (Latency)")
        print(f"  • Min Response Time    : {report['response_time_ms']['min']} ms")
        print(f"  • Average Response Time: {report['response_time_ms']['avg']} ms")
        print(f"  • Median (p50)         : {report['response_time_ms']['median_p50']} ms")
        print(f"  • 90th Percentile (p90): {report['response_time_ms']['p90']} ms")
        print(f"  • 95th Percentile (p95): {report['response_time_ms']['p95']} ms")
        print(f"  • 99th Percentile (p99): {report['response_time_ms']['p99']} ms")
        print(f"  • Max Response Time    : {report['response_time_ms']['max']} ms")
        print("================================================================")

        with open("load_test_results.json", "w") as f:
            json.dump(report, f, indent=2)

        return report

if __name__ == "__main__":
    duration = DURATION_SECONDS
    if len(sys.argv) > 1:
        try:
            duration = int(sys.argv[1])
        except ValueError:
            pass
    tester = LoadTester(TARGET_URL, CONCURRENCY, duration)
    asyncio.run(tester.run())
