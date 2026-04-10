#!/bin/bash

# --- CONFIGURACIÓN ---
# Nueva ruta raíz solicitada
DESTINO="/backup"
DB_NAME="uisil_sistema"
FECHA=$(date +"%Y-%m-%d_%H-%M")
ARCHIVO_RESPALDO="backup_db_${FECHA}.sql"
LOG_FILE="$DESTINO/backup_log.log"

# 1. VERIFICACIÓN Y CREACIÓN DE CARPETA 
if [ ! -d "$DESTINO" ]; then
    echo "Carpeta no existe. Creándola en $DESTINO..."
    sudo mkdir -p "$DESTINO"
    sudo chmod 777 "$DESTINO"
fi

# 2. RESPALDO DE LA BASE DE DATOS
echo "[$(date)] Iniciando respaldo de $DB_NAME..." >> "$LOG_FILE"
pg_dump -U postgres "$DB_NAME" > "$DESTINO/$ARCHIVO_RESPALDO"

# 3. COMPRESIÓN DEL ARCHIVO 
# El nombre incluirá fecha y hora
gzip "$DESTINO/$ARCHIVO_RESPALDO"

if [ $? -eq 0 ]; then
    echo "[$(date)] Respaldo exitoso: ${ARCHIVO_RESPALDO}.gz" >> "$LOG_FILE"
else
    echo "[$(date)] ERROR: El respaldo falló" >> "$LOG_FILE"
fi
