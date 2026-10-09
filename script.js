// script.js - Incident Monitoring & DockHub Portal Logic

let incidents = [];
let resolved = 0;
let currentUser = null;

// Initialize sample data
document.addEventListener('DOMContentLoaded', () => {
    updateDashboard();
    checkSession();
});

function showSection(id) {
    document.querySelectorAll('.section').forEach(sec => {
        sec.classList.remove('active');
    });

    const target = document.getElementById(id);
    if (target) {
        target.classList.add('active');
    }
}

function handleLogin(event) {
    if (event) event.preventDefault();
    const email = document.getElementById('loginEmail')?.value || '';
    const password = document.getElementById('loginPassword')?.value || '';
    const role = document.getElementById('userRole')?.value || 'User';

    if (!email || !password) {
        showAuthMessage('Please enter both email and password.', 'error');
        return false;
    }

    if (password.length < 6) {
        showAuthMessage('Password must be at least 6 characters.', 'error');
        return false;
    }

    currentUser = { email, role, token: 'session_token_' + Date.now() };
    localStorage.setItem('dockhub_user', JSON.stringify(currentUser));
    
    showAuthMessage(`Welcome back, ${email}! Role: ${role}`, 'success');
    updateSessionUI();
    return false;
}

function handleLogout() {
    currentUser = null;
    localStorage.removeItem('dockhub_user');
    updateSessionUI();
    showAuthMessage('Logged out successfully.', 'info');
}

function resetSession() {
    currentUser = null;
    localStorage.clear();
    sessionStorage.clear();
    updateSessionUI();
}

function checkSession() {
    const saved = localStorage.getItem('dockhub_user');
    if (saved) {
        try {
            currentUser = JSON.parse(saved);
            updateSessionUI();
        } catch (e) {
            localStorage.removeItem('dockhub_user');
        }
    }
}

function updateSessionUI() {
    const statusText = document.getElementById('userStatusText');
    const loginForm = document.getElementById('loginFormContainer');
    const userProfile = document.getElementById('userProfileContainer');

    if (currentUser) {
        if (statusText) statusText.innerText = `Logged in as: ${currentUser.email} (${currentUser.role})`;
        if (loginForm) loginForm.style.display = 'none';
        if (userProfile) userProfile.style.display = 'block';
    } else {
        if (statusText) statusText.innerText = 'Not logged in';
        if (loginForm) loginForm.style.display = 'block';
        if (userProfile) userProfile.style.display = 'none';
    }
}

function showAuthMessage(msg, type) {
    const box = document.getElementById('authMessageBox');
    if (box) {
        box.innerText = msg;
        box.className = 'auth-msg ' + type;
        box.style.display = 'block';
    }
}

function addIncident() {
    const title = document.getElementById('title')?.value || '';
    const desc = document.getElementById('description')?.value || '';
    const severity = document.getElementById('severity')?.value || 'Low';

    if (!title.trim() || !desc.trim()) {
        const alertBox = document.getElementById('incidentFormNotice');
        if (alertBox) {
            alertBox.innerText = 'Please fill all required fields.';
            alertBox.className = 'alert-notice error';
            alertBox.style.display = 'block';
        }
        return;
    }

    const id = 'INC-' + (incidents.length + 1001);
    incidents.push({
        id,
        title,
        desc,
        severity,
        status: 'Open',
        timestamp: new Date().toLocaleTimeString()
    });

    updateDashboard();
    renderIncidents();

    if (document.getElementById('title')) document.getElementById('title').value = '';
    if (document.getElementById('description')) document.getElementById('description').value = '';

    const alertBox = document.getElementById('incidentFormNotice');
    if (alertBox) {
        alertBox.innerText = `Incident ${id} created successfully.`;
        alertBox.className = 'alert-notice success';
        alertBox.style.display = 'block';
    }
}

function updateDashboard() {
    const totalEl = document.getElementById('totalIncidents');
    const resolvedEl = document.getElementById('resolvedIncidents');
    const criticalEl = document.getElementById('criticalAlerts');

    if (totalEl) totalEl.innerText = incidents.length;
    if (resolvedEl) resolvedEl.innerText = resolved;
    if (criticalEl) {
        const critical = incidents.filter(i => i.severity === 'Critical').length;
        criticalEl.innerText = critical;
    }
}

function renderIncidents() {
    const list = document.getElementById('incidentList');
    if (!list) return;
    list.innerHTML = '';

    if (incidents.length === 0) {
        list.innerHTML = '<li class="empty-msg">No active incidents.</li>';
        return;
    }

    incidents.forEach((item, index) => {
        const li = document.createElement('li');
        li.className = `incident-card severity-${item.severity.toLowerCase()}`;
        li.innerHTML = `
            <div class="card-header">
                <strong>[${item.id}] ${item.title}</strong>
                <span class="badge ${item.severity.toLowerCase()}">${item.severity}</span>
            </div>
            <p>${item.desc}</p>
            <div class="card-footer">
                <small>Reported at: ${item.timestamp}</small>
                <button onclick="resolveIncident(${index})" class="btn-resolve">Resolve</button>
            </div>
        `;
        list.appendChild(li);
    });
}

function resolveIncident(index) {
    if (index >= 0 && index < incidents.length) {
        incidents.splice(index, 1);
        resolved++;
        updateDashboard();
        renderIncidents();
    }
}

function handleFileUpload(event) {
    const fileInput = document.getElementById('evidenceFile');
    const statusBox = document.getElementById('uploadStatus');
    if (fileInput && fileInput.files.length > 0) {
        const file = fileInput.files[0];
        if (statusBox) {
            statusBox.innerText = `File uploaded successfully: ${file.name} (${(file.size / 1024).toFixed(1)} KB)`;
            statusBox.className = 'upload-status success';
            statusBox.style.display = 'block';
        }
    } else {
        if (statusBox) {
            statusBox.innerText = 'Please select a file to upload.';
            statusBox.className = 'upload-status error';
            statusBox.style.display = 'block';
        }
    }
}

function downloadReport() {
    let text = "DockHub Bio - Secure Incident Monitoring Report\n";
    text += "Generated: " + new Date().toISOString() + "\n";
    text += "=================================================\n\n";

    if (incidents.length === 0) {
        text += "No active incidents recorded.\n";
    } else {
        incidents.forEach((item, i) => {
            text += `${i + 1}. [${item.id}] ${item.title} (Severity: ${item.severity})\n`;
            text += `   Description: ${item.desc}\n`;
            text += `   Timestamp: ${item.timestamp}\n\n`;
        });
    }

    const blob = new Blob([text], { type: "text/plain" });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = "incident_report.txt";
    a.click();
}
