<h1>
  <img src="media/logo.png" width="30" align="center">
  WinTrack 
</h1>
  
A Windows desktop screen-time tracking application built using:

- PySide6 (Desktop application & system tray integration)
- FastAPI (Local backend API)
- SQLite (Persistent data storage)
- React + Vite (Interactive dashboard frontend)
- Chart.js (Data visualization and analytics)
- PyInstaller (Executable `(.exe)` packaging)
- Inno Setup (Windows installer creation)

The application monitors active window usage and provides:
- Detailed daily usage statistics
- Weekly usage trends and analytics
- Monthly summaries and aggregated insights

[Discord](https://discord.gg/UGsYzs8DMK)

---

# Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Local Development](#local-development)
- [Building Production App](#building-production-app)
- [Versioning System](#versioning-system)
- [Release Flow](#release-flow)

---

## Features
- Real-time application usage tracking
- Automatic detection of inactive/idle time with smart handling
- Customizable inactive time threshold
- Daily usage breakdown
- Weekly usage trends (interactive line charts)
- Monthly productivity summaries
- In-app update notifications
- System tray integration for background operation
---

## Screenshots
![Daily](media/screenshots/daily.png)
![Weekly](media/screenshots/weekly.png)
![Monthly](media/screenshots/monthly.png)

---

## Architecture
```mermaid
%%{init: {
  "theme": "base",
  "themeVariables": {
    "background": "#0f172a",
    "primaryColor": "#1e293b",
    "primaryTextColor": "#e2e8f0",
    "primaryBorderColor": "#334155",
    "lineColor": "#64748b",
    "secondaryColor": "#1e293b",
    "tertiaryColor": "#1e293b",
    "fontFamily": "monospace"
  }
}}%%

graph TD
    A[User] -->|Interact via tray / app| B[PySide6 GUI<br>gui/interface.py → python -m gui.interface]

    subgraph "GUI Layer (gui/)"
        B --> C[QSystemTrayIcon<br>Start/Pause/Quit/Open Dashboard]
        B --> D[Main Window / Settings]
        B --> E[QThread Worker Launch]
    end

    E --> F[Screen Time Worker<br>st_tracker/worker.py]

    subgraph "Tracking Layer (st_tracker/)"
        F --> G[Periodic Polling Loop<br>~1-5s interval]
        G --> H[Windows API Calls<br>→ win32gui.GetForegroundWindow<br>→ win32process.GetWindowThreadProcessId<br>→ GetModuleFileNameEx / psutil]
        H --> I[Get: process name, exe path, window title]
        G --> J[Idle / AFK Check<br>→ GetLastInputInfo or similar]
        J -->|Idle > threshold| K[Pause accumulation<br>Mark as INACTIVE]
        I -->|Active window change| L[Calculate duration slice<br>Current - last timestamp]
        L --> M[Create usage record<br>timestamp + app + title + duration + active flag]
        M --> N[Save to SQLite<br>via shared/db or backend/database.py helper]
    end

    subgraph "Backend / API Layer (backend/)"
        N --> O[FastAPI Application<br>backend/api.py]
        O --> P[Key Endpoints]
        P --> Q[GET /api/daily<br>→ aggregated daily stats]
        P --> R[GET /api/weekly<br>→ time-series data for line chart]
        P --> S[GET /api/monthly<br>→ monthly totals / breakdown]
        O --> T[Serve Static Files<br>frontend/dist/ → React build]
        O --> U[SPA Fallback Route<br>catch-all → index.html]
        O -->|DB access| V[SQLite Connection<br>backend/database.py]
    end

    subgraph "Frontend Dashboard (frontend/ → React + Vite)"
        W[Tray → 'Open Dashboard'] --> X[Browser opens http://localhost:port]
        X --> Y[React SPA<br>src/App.tsx / main entry]
        Y -->|fetch / axios| Q
        Y -->|fetch / axios| R
        Y -->|fetch / axios| S
        Q & R & S --> Z[Chart.js renders:<br>→ Daily pie/bar<br>→ Weekly line/area<br>→ Monthly summary]
        Z --> AA[Interactive UI<br>totals, top apps, trends, tooltips]
    end

    subgraph "Shared Utilities"
        AB[shared/ → constants / models / db helpers<br>e.g. DB path, schemas, API base]
        AB -.-> F
        AB -.-> O
        AB -.-> Y
    end

    style A fill:#7c3aed,stroke:#e2e8f0,color:#ffffff
    style W fill:#2563eb,stroke:#e2e8f0,color:#ffffff
    style AA fill:#059669,stroke:#e2e8f0,color:#ffffff
```

---

## Project Structure
```
WinTrack/
│
├── backend/                #FastAPI backend
├── frontend/               #React + Vite dashboard
├── gui/                    #PySide6 system tray app
├── shared/                 #Shared utilities (paths, memory, status)
├── version.json            #Local app version
├── remote_version.json     #Remote version checker
```

---

## Local Development

### 1. Clone
```
git clone https://github.com/sr1k7nth/WinTrack.git
cd WinTrack
```

### 2. Backend Setup
```
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Frontend Setup
```
cd frontend
npm install
npm run dev
```

Dashboard runs at:
`http://localhost:7070`
Backend runs at:
`http://127.0.0.1:7777`

- - -

## Building Production App

### Building the Executable
```
pyinstaller --onedir ^
--icon=media/logo.ico ^
--add-data "media;media" ^
--add-data "frontend/dist;frontend/dist" ^
--add-data "version.json;." ^
--name WinTrack ^
--paths=. ^
gui/interface.py
```

## Creating Installer

1. Open WinTrack.iss
2. Update:
   `#define MyAppVersion "x.x.x"`
3. Compile in Inno Setup

⚠️ **Do NOT change AppId between versions.**

---

## Versioning System

WinTrack uses a lightweight remote version-check mechanism.

- `version.json` → Current installed application version
- `remote_version.json` → Latest available release version (hosted on GitHub)

On startup, the app requests:
`https://raw.githubusercontent.com/sr1k7nth/WinTrack/main/remote_version.json`

If:
`latest_version > current_version`
An update notification banner is displayed inside the dashboard.

---

## Release Flow

1. Update version.json
2. Clean build (delete dist/ build/)
3. Rebuild executable
4. Update Inno Setup version
5. Compile installer
6. Upload installer to GitHub Releases
7. Update remote_version.json