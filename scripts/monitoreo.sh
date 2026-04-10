#!/bin/bash

# --- CONFIGURACIÓN ---
DESTINO="/backup"
LOG_FILE="$DESTINO/monitoreo.log"
# Límites según rúbrica [cite: 93]
LIMITE_CPU=80
LIMITE_RAM=80
LIMITE_DISCO=90

AHORA=$(date "+%Y-%m-%d %H:%M:%S")

# 1. VERIFICAR QUE EXISTA LA CARPETA RAÍZ
if [ ! -d "$DESTINO" ]; then
    sudo mkdir -p "$DESTINO"
    sudo chmod 777 "$DESTINO"
fi

# 2. MONITOREO DE DISCO (Herramienta sugerida: df) [cite: 95]
USO_DISCO=$(df / | grep / | awk '{ print $5 }' | sed 's/%//')
if [ "$USO_DISCO" -gt "$LIMITE_DISCO" ]; then
    echo "[$AHORA]" >> "$LOG_FILE"
    echo "ALERTA: Disco excedido" >> "$LOG_FILE"
    echo "Uso actual: $USO_DISCO%" >> "$LOG_FILE"
fi

# 3. MONITOREO DE RAM (Herramienta sugerida: free) [cite: 95]
USO_RAM=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
if [ "$USO_RAM" -gt "$LIMITE_RAM" ]; then
    # Identificar proceso responsable [cite: 97]
    PROCESO=$(ps -eo pid,comm,%mem --sort=-%mem | head -n 2 | tail -n 1)
    echo "[$AHORA]" >> "$LOG_FILE"
    echo "ALERTA: RAM excedida" >> "$LOG_FILE"
    echo "Uso actual: $USO_RAM%" >> "$LOG_FILE"
    echo "Proceso: $(echo $PROCESO | awk '{print $2}')" >> "$LOG_FILE"
    echo "PID: $(echo $PROCESO | awk '{print $1}')" >> "$LOG_FILE"
fi

# 4. MONITOREO DE CPU (Herramienta sugerida: top) [cite: 95]
USO_CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)
if [ "$USO_CPU" -gt "$LIMITE_CPU" ]; then
    # Identificar proceso responsable [cite: 97, 105]
    PROCESO_CPU=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 2 | tail -n 1)
    echo "[$AHORA]" >> "$LOG_FILE"
    echo "ALERTA: CPU excedido" >> "$LOG_FILE"
    echo "Uso actual: $USO_CPU%" >> "$LOG_FILE"
    echo "Proceso: $(echo $PROCESO_CPU | awk '{print $2}')" >> "$LOG_FILE"
    echo "PID: $(echo $PROCESO_CPU | awk '{print $1}')" >> "$LOG_FILE"
fi
