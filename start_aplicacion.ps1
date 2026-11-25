$ErrorActionPreference = "Stop"

function Levantar-Docker {
    Write-Host "Levantando el contenedor de MongoDB..." -ForegroundColor Cyan
    cd backend
    docker compose -f docker-compose.mongo.yml up -d
    cd ..
    Write-Host "Docker levantado." -ForegroundColor Green
}

function Levantar-Frontend {
    Write-Host "Iniciando el frontend..." -ForegroundColor Cyan
    Start-Process "cmd.exe" -ArgumentList "/c title Frontend IA Dental && pnpm run dev"
    Write-Host "Frontend iniciado en ventana separada." -ForegroundColor Green
}

function Levantar-Backend {
    Write-Host "Iniciando el backend (uvicorn)..." -ForegroundColor Cyan
    $activateScript = ".\backend\.venv\Scripts\activate.bat"
    $startBackendCmd = ""
    if (Test-Path $activateScript) {
        $startBackendCmd = "/c `"title Backend IA Dental && cd backend && `".\.venv\Scripts\activate.bat`" && uvicorn main:app --reload --host 0.0.0.0 --port 8000`""
    } else {
        Write-Host "Advertencia: No se encontró el entorno virtual en backend\.venv" -ForegroundColor Yellow
        $startBackendCmd = "/c `"title Backend IA Dental && cd backend && uvicorn main:app --reload --host 0.0.0.0 --port 8000`""
    }
    Start-Process "cmd.exe" -ArgumentList $startBackendCmd
    Write-Host "Backend iniciado en ventana separada." -ForegroundColor Green
}

function Levantar-Todo {
    Levantar-Docker
    Start-Sleep -Seconds 2
    Levantar-Backend
    Levantar-Frontend
}

function Cerrar-Docker {
    if (Test-Path "backend\docker-compose.mongo.yml") {
        cd backend
        Write-Host "Deteniendo contenedor de MongoDB..." -ForegroundColor Cyan
        docker compose -f docker-compose.mongo.yml stop
        cd ..
    } else {
        Write-Host "No se encontró el archivo docker-compose.mongo.yml en backend." -ForegroundColor Yellow
    }
}

function Cerrar-Frontend {
    Write-Host "Deteniendo procesos del frontend..." -ForegroundColor Cyan
    # Detener procesos de Node/Vite/Pnpm
    Get-CimInstance Win32_Process | Where-Object { 
        $_.CommandLine -match "vite" -or $_.CommandLine -match "pnpm" 
    } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

    # Cerrar ventana cmd
    Get-Process | Where-Object { $_.MainWindowTitle -match "Frontend IA Dental" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "Frontend detenido." -ForegroundColor Green
}

function Cerrar-Backend {
    Write-Host "Deteniendo procesos del backend..." -ForegroundColor Cyan
    # Detener procesos de Python/Uvicorn
    Get-CimInstance Win32_Process | Where-Object { 
        $_.CommandLine -match "uvicorn"
    } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

    # Intentar cerrar la ventana por si acaso
    Get-Process | Where-Object { $_.MainWindowTitle -match "Backend IA Dental" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "Backend detenido." -ForegroundColor Green
}

function Cerrar-Todo {
    Write-Host "Cerrando la aplicación de IA Dental..." -ForegroundColor Green
    Cerrar-Docker
    Cerrar-Backend
    Cerrar-Frontend
    Write-Host "Aplicación detenida completamente." -ForegroundColor Green
}

do {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   Gestión de la Aplicación IA Dental    " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host " --- Opciones para Levantar ---"
    Write-Host " 1. Levantar Docker (MongoDB - Backend)"
    Write-Host " 2. Levantar Backend (Uvicorn)"
    Write-Host " 3. Levantar Frontend (Vite)"
    Write-Host " 4. Levantar TODO (MongoDB + Backend + Frontend)"
    Write-Host " --- Opciones para Cerrar ---"
    Write-Host " 5. Cerrar Docker (MongoDB - Backend)"
    Write-Host " 6. Cerrar Backend (Uvicorn)"
    Write-Host " 7. Cerrar Frontend (Vite)"
    Write-Host " 8. Cerrar TODO"
    Write-Host " ----------------------------"
    Write-Host " 9. Salir"
    Write-Host "=========================================" -ForegroundColor Cyan
    $opcion = Read-Host "Elige una opción (1-9)"

    switch ($opcion) {
        "1" { Levantar-Docker }
        "2" { Levantar-Backend }
        "3" { Levantar-Frontend }
        "4" { Levantar-Todo }
        "5" { Cerrar-Docker }
        "6" { Cerrar-Backend }
        "7" { Cerrar-Frontend }
        "8" { Cerrar-Todo }
        "9" { Write-Host "Saliendo..." -ForegroundColor Green }
        default { Write-Host "Opción no válida. Por favor, elige una opción entre 1 y 9." -ForegroundColor Red }
    }
} while ($opcion -ne "9")
