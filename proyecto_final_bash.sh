#!/bin/bash

# Variables de configuración
LOCAL_DIR="/ruta/local/de/archivos"    
REMOTE_USER="usuario_remoto"           
REMOTE_HOST="servidor_remoto.com"      
REMOTE_DIR="/ruta/remota/de/archivos"  
LOG_FILE="registro_actualizaciones.log"

# Códigos de colores
COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_RED="\e[31m"
COLOR_YELLOW="\e[33m"
COLOR_BLUE="\e[34m"
COLOR_CYAN="\e[36m"
COLOR_MAGENTA="\e[35m"
COLOR_WHITE="\e[97m"
COLOR_BOLD="\e[1m"
COLOR_UNDERLINE="\e[4m"

# Función para limpiar archivos temporales
limpiar_archivos() {
    echo -e "${COLOR_YELLOW}🚮 Limpiando archivos temporales...${COLOR_RESET}" | tee -a "$LOG_FILE"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo -e "${COLOR_MAGENTA}🔍 Eliminando archivos en %TEMP%...${COLOR_RESET}" | tee -a "$LOG_FILE"
        rm -rf "/c/Users/$USER/AppData/Local/Temp/*"
    else
        sudo rm -rf /tmp/* | tee -a "$LOG_FILE"
        sudo apt-get clean | tee -a "$LOG_FILE"
    fi
    echo -e "${COLOR_GREEN}✅ Limpieza completada.${COLOR_RESET}" | tee -a "$LOG_FILE"
}

# Función para verificar e instalar actualizaciones
verificar_e_instalar_actualizaciones() {
    echo -e "${COLOR_CYAN}🔄 Verificando e instalando actualizaciones...${COLOR_RESET}" | tee -a "$LOG_FILE"
    
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        if ! command -v winget &> /dev/null; then
            echo -e "${COLOR_RED}❌ winget no está disponible.${COLOR_RESET}" | tee -a "$LOG_FILE"
            return
        fi
        echo -e "${COLOR_BLUE}💡 Actualizando sistema en Windows...${COLOR_RESET}" | tee -a "$LOG_FILE"
        winget upgrade --all --accept-source-agreements --accept-package-agreements | tee -a "$LOG_FILE"
    else
        echo -e "${COLOR_BLUE}💡 Actualizando sistema en Linux...${COLOR_RESET}" | tee -a "$LOG_FILE"
        
        # Filtrar la salida de apt-get para eliminar cualquier línea que contenga 'stdout is not a tty'
        sudo apt-get update -y 2>&1 | grep -v "stdout is not a tty" | tee -a "$LOG_FILE"
        sudo apt-get upgrade -y 2>&1 | grep -v "stdout is not a tty" | tee -a "$LOG_FILE"

        if [ $? -eq 0 ]; then
            echo -e "${COLOR_GREEN}✅ Actualización completada con éxito.${COLOR_RESET}" | tee -a "$LOG_FILE"
        else
            echo -e "${COLOR_RED}❌ Error en la actualización.${COLOR_RESET}" | tee -a "$LOG_FILE"
        fi
    fi
}



# Función para sincronizar archivos
sincronizar_archivos() {
    echo -e "${COLOR_YELLOW}📂 Sincronizando archivos...${COLOR_RESET}" | tee -a "$LOG_FILE"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        DESTINO="C:/ruta/del/destino"
        robocopy "$LOCAL_DIR" "$DESTINO" /MIR | tee -a "$LOG_FILE"
    else
        rsync -avz --delete "$LOCAL_DIR/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" | tee -a "$LOG_FILE"
    fi
    [[ $? -eq 0 ]] && echo -e "${COLOR_GREEN}✅ Sincronización completada con éxito.${COLOR_RESET}" | tee -a "$LOG_FILE" || echo -e "${COLOR_RED}❌ Error en la sincronización.${COLOR_RESET}" | tee -a "$LOG_FILE"
}

# Función para mostrar el menú
mostrar_menu() {
    echo -e "${COLOR_CYAN}${COLOR_BOLD}---------------------------------------${COLOR_RESET}"
    echo -e "${COLOR_CYAN}${COLOR_BOLD}          Menú de Opciones             ${COLOR_RESET}"
    echo -e "${COLOR_CYAN}${COLOR_BOLD}---------------------------------------${COLOR_RESET}"
    echo -e "${COLOR_WHITE}${COLOR_BOLD} 1.${COLOR_YELLOW} 🚮 Limpiar archivos temporales y caché${COLOR_RESET}"
    echo -e "${COLOR_WHITE}${COLOR_BOLD} 2.${COLOR_CYAN} 🔄 Verificar e instalar actualizaciones${COLOR_RESET}"
    echo -e "${COLOR_WHITE}${COLOR_BOLD} 3.${COLOR_GREEN} 📂 Sincronizar archivos con servidor remoto${COLOR_RESET}"
    echo -e "${COLOR_WHITE}${COLOR_BOLD} 4.${COLOR_RED} ❌ Salir${COLOR_RESET}"
    echo -e "${COLOR_CYAN}${COLOR_BOLD}---------------------------------------${COLOR_RESET}"
}

# Bucle del menú interactivo
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion
    case $opcion in
        1) limpiar_archivos ;;
        2) verificar_e_instalar_actualizaciones ;;
        3) sincronizar_archivos ;;
        4) echo -e "${COLOR_RED}❌ Saliendo...${COLOR_RESET}" | tee -a "$LOG_FILE"; exit 0 ;;
        *) echo -e "${COLOR_RED}⚠️ Opción no válida.${COLOR_RESET}" | tee -a "$LOG_FILE" ;;
    esac
done
