// script.js

let incidents = [];
let resolved = 0;

function showSection(id){

document.querySelectorAll('.section').forEach(sec=>{
sec.classList.remove('active');
});

document.getElementById(id).classList.add('active');

}

function addIncident(){

let title = document.getElementById('title').value;
let desc = document.getElementById('description').value;
let severity = document.getElementById('severity').value;

if(title === '' || desc === ''){
alert("Please fill all fields");
return;
}

incidents.push({
title,
desc,
severity
});

updateDashboard();
renderIncidents();

document.getElementById('title').value='';
document.getElementById('description').value='';

alert("Incident Submitted Successfully");

}

function updateDashboard(){

document.getElementById('totalIncidents').innerText = incidents.length;
document.getElementById('resolvedIncidents').innerText = resolved;

let critical = incidents.filter(i => i.severity === "Critical").length;
document.getElementById('criticalAlerts').innerText = critical;

}

function renderIncidents(){

let list = document.getElementById('incidentList');
list.innerHTML='';

incidents.forEach((item,index)=>{

let li = document.createElement('li');

li.innerHTML = `
<b>${item.title}</b><br>
${item.desc}<br>
Severity: ${item.severity}<br><br>
<button onclick="resolveIncident(${index})">Resolve</button>
`;

list.appendChild(li);

});

}

function resolveIncident(index){

incidents.splice(index,1);
resolved++;

updateDashboard();
renderIncidents();

}

function downloadReport(){

let text = "Secure Incident Monitoring Report\n\n";

incidents.forEach((item,i)=>{
text += `${i+1}. ${item.title} - ${item.severity}\n${item.desc}\n\n`;
});

let blob = new Blob([text], {type:"text/plain"});
let a = document.createElement('a');
a.href = URL.createObjectURL(blob);
a.download = "incident_report.txt";
a.click();

}

showSection('dashboard');