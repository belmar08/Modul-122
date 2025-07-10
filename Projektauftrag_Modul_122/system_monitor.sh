#!/bin/bash
# -----------------------------------------------------------------------------
# Script Name : system_monitor.sh
# Beschreibung: Das Skript überwacht CPU, RAM, Speicher, Benutzer, Netzwerk und
#               fehlgeschlagene Logins. Es schreibt Logs und sendet bei hoher
#               CPU-Auslastung (>10 %) automatisch eine E-Mail, das folgende
#               macht es auch bei RAM. Läuft regelmässig per Cronjob.
# Autor       : Marco Belk
# Datum       : 11.07.2025
# Version     : 1.0
# Änderungen  : 27.06.2025 --> Beginn des Projektes erste Daten hinzugefügt.
#               04.07.2025 --> Weiterarbeitung des Skripts (fertigstellung)
#               07.07.2025 --> Kleine Anpassungen von Zuhause.
#               11.07.2025 --> Abgabe/Auführung dieses Skriptes.
# -----------------------------------------------------------------------------

# Absolute Pfade für Befehle (damit Cron sie findet)
BC=/usr/bin/bc
WHO=/usr/bin/who
WC=/usr/bin/wc
GREP=/bin/grep
DATE=/bin/date
DF=/bin/df
CAT=/bin/cat

# Konfigurationsdatei
CONFIG="/home/marco/system-monitor/config.cfg"

# Log- und Report-Dateien
LOGFILE="/home/marco/system-monitor/system_monitor.log"
REPORT="/home/marco/system-monitor/system_warning_$($DATE '+%Y-%m-%d_%H-%M').log"

# Config laden
if [[ ! -e "$CONFIG" ]]; then
  echo "$($DATE): Achtung: Datei "$CONFIG" fehlt!" >> "$LOGFILE"
  exit 1
fi

. "$CONFIG"

# Systemwerte ermitteln
CPU_USAGE=$($CAT /proc/loadavg | awk '{print $1}')
MEMORY_USAGE=$(free -m | awk '/Mem:/ {print $3}')
# Angemeldeten Benutzer
USERS=$(who | wc -l)
# Fehlgeschlagene Loginversuche
TIME_STR=$(date --date='5 minutes ago' '+%b %_d %H:%M')
FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log 2>/dev/null | grep "$TIME_STR" | wc -l)
# WLAN0
if [ -e /sys/class/net/wlan0/operstate ]; then
  WLAN0_STATUS=$(cat /sys/class/net/wlan0/operstate)
else
  WLAN0_STATUS="unknown"
fi
# ETH0
if [ -e /sys/class/net/eth0/operstate ]; then
  ETH0_STATUS=$(cat /sys/class/net/eth0/operstate)
else
  ETH0_STATUS="unknown"
fi
# Freier Speicherplatz
DISK_FREE=$(df / --output=avail | tail -1)


# Bericht schreiben
{
  echo "====== System Monitoring Report ======"
  echo "Bericht erstellt am: $($DATE '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "CPU:                          $CPU_LOAD" # Jede Minute
  echo "RAM (MB):                     $MEMORY_USAGE"
  echo "Freier Speicherplatz:         $DISK_FREE"
  echo "Angemeldete Benutzer:         $USERS"
  echo ""
  echo "Netzwerk Status:"
  echo "  - eth0:                     $ETH0_STATUS"
  echo "  - wlan0:                    $WLAN0_STATUS"
  echo ""
  echo "Loginversuche (5 min):        $FAILED_LOGINS"
  echo "======================================"
} > "$REPORT"

# CPU
if (( $(echo "$CPU_USAGE > $CPU_WARN" | $BC -l) )); then
  WARNUNG="ACHTUNG: Der RAM-Verbrauch hat das Limit von $CPU_WARN MB überschritten (aktuell: $CPU_USAGE MB)."
  echo "$WARNUNG" | tee -a "$REPORT"
  {
    echo "Subject: Warnung: CPU-Auslastung kritisch auf $(hostname)"
    echo "To: $WARNUNGS_EMAIL"
    echo
    echo "$WARNUNG am $($DATE)"
  } | /usr/bin/msmtp --from=default -t
fi

# RAM
if (( $MEMORY_USAGE > $MEMORY_WARN )); then
  WARNUNG="ACHTUNG: Der RAM-Verbrauch hat das Limit von $MEMORY_WARN MB überschritten (aktuell: $MEMORY_USAGE M>  echo "$WARNUNG" | tee -a "$REPORT"
  {
    echo "Subject: Warnung: RAM-Verbrauch kritisch auf $(hostname)"
    echo "To: $WARNUNGS_EMAIL"
    echo
    echo "$WARNUNG am $($DATE)"
  } | /usr/bin/msmtp --from=default -t
fi

# Skript-Ausführung
echo "$(date '+%Y-%m-%d %H:%M:%S') | CPU: $CPU_LOAD | RAM: $RAM_USED MB | Check abgeschlossen" >> "$LOGFILE"
