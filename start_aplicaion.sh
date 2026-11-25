#!/bin/bash

# start_aplicaion.sh
# Equivalente en Linux al start_aplicacion.ps1

LEVANTAR_DOCKER() {
    echo -e "\e[36mLevantando el contenedor de MongoDB...\e[0m"
    if [ -d "backend" ]; then
        cd backend
        docker compose -f docker-compose.mongo.yml up -d
        cd ..
        echo -e "\e[32mDocker levantado.\e[0m"
    else
        echo -e "\e[33mNo se encontró la carpeta backend.\e[0m"
    fi
}

LEVANTAR_FRONTEND() {
    echo -e "\e[36mIniciando el frontend...\e[0m"
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal --title="Frontend IA Dental" -- bash -c "pnpm run dev; exec bash"
    elif command -v x-terminal-emulator &> /dev/null; then
        x-terminal-emulator -T "Frontend IA Dental" -e bash -c "pnpm run dev; exec bash" &
    else
        echo -e "\e[33mNo se encontró un emulador de terminal (gnome-terminal/xterm). Ejecutando en background...\e[0m"
        nohup pnpm run dev > frontend.log 2>&1 &
    fi
    echo -e "\e[32mFrontend iniciado.\e[0m"
}

LEVANTAR_BACKEND() {
    echo -e "\e[36mIniciando el backend (uvicorn)...\e[0m"

    local CMD=""
    if [ -f "backend/.venv/bin/activate" ]; then
        CMD="cd backend && source .venv/bin/activate && uvicorn main:app --reload --host 0.0.0.0 --port 8000; exec bash"
    else
        echo -e "\e[33mAdvertencia: No se encontró el entorno virtual en backend/.venv\e[0m"
        CMD="cd backend && uvicorn main:app --reload --host 0.0.0.0 --port 8000; exec bash"
    fi

    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal --title="Backend IA Dental" -- bash -c "$CMD"
    elif command -v x-terminal-emulator &> /dev/null; then
        x-terminal-emulator -T "Backend IA Dental" -e bash -c "$CMD" &
    else
        echo -e "\e[33mNo se encontró un emulador de terminal. Ejecutando en background...\e[0m"
        nohup bash -c "${CMD/exec bash/}" > backend.log 2>&1 &
    fi

    echo -e "\e[32mBackend iniciado.\e[0m"
}

LEVANTAR_TODO() {
    LEVANTAR_DOCKER
    sleep 2
    LEVANTAR_BACKEND
    LEVANTAR_FRONTEND
}

CERRAR_DOCKER() {
    if [ -f "backend/docker-compose.mongo.yml" ]; then
        cd backend
        echo -e "\e[36mDeteniendo contenedor de MongoDB...\e[0m"
        docker compose -f docker-compose.mongo.yml stop
        cd ..
    else
        echo -e "\e[33mNo se encontró el archivo docker-compose.mongo.yml en backend.\e[0m"
    fi
}

CERRAR_FRONTEND() {
    echo -e "\e[36mDeteniendo procesos del frontend...\e[0m"
    pkill -f "vite"
    pkill -f "pnpm"
    echo -e "\e[32mFrontend detenido.\e[0m"
}

CERRAR_BACKEND() {
    echo -e "\e[36mDeteniendo procesos del backend...\e[0m"
    pkill -f "uvicorn"
    echo -e "\e[32mBackend detenido.\e[0m"
}

CERRAR_TODO() {
    echo -e "\e[32mCerrando la aplicación de IA Dental...\e[0m"
    CERRAR_DOCKER
    CERRAR_BACKEND
    CERRAR_FRONTEND
    echo -e "\e[32mAplicación detenida completamente.\e[0m"
}

while true; do
    echo ""
    echo -e "\e[36m=========================================\e[0m"
    echo -e "\e[36m   Gestión de la Aplicación IA Dental    \e[0m"
    echo -e "\e[36m=========================================\e[0m"
    echo " --- Opciones para Levantar ---"
    echo " 1. Levantar Docker (MongoDB - Backend)"
    echo " 2. Levantar Backend (Uvicorn)"
    echo " 3. Levantar Frontend (Vite)"
    echo " 4. Levantar TODO (MongoDB + Backend + Frontend)"
    echo " --- Opciones para Cerrar ---"
    echo " 5. Cerrar Docker (MongoDB - Backend)"
    echo " 6. Cerrar Backend (Uvicorn)"
    echo " 7. Cerrar Frontend (Vite)"
    echo " 8. Cerrar TODO"
    echo " ----------------------------"
    echo " 9. Salir"
    echo -e "\e[36m=========================================\e[0m"
    read -p "Elige una opción (1-9): " opcion

    case $opcion in
        1) LEVANTAR_DOCKER ;;
        2) LEVANTAR_BACKEND ;;
        3) LEVANTAR_FRONTEND ;;
        4) LEVANTAR_TODO ;;
        5) CERRAR_DOCKER ;;
        6) CERRAR_BACKEND ;;
        7) CERRAR_FRONTEND ;;
        8) CERRAR_TODO ;;
        9) echo -e "\e[32mSaliendo...\e[0m"; exit 0 ;;
        *) echo -e "\e[31mOpción no válida. Por favor, elige una opción entre 1 y 9.\e[0m" ;;
    esac
done

#Para ejecutar el script, asegúrate de darle permisos de ejecución con:
#chmod +x start_aplicaion.sh
#LIBGL_ALWAYS_SOFTWARE=1 bash start_aplicaion.sh