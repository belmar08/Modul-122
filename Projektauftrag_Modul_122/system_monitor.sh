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
BC=/usr/bin/bc   # Für mathematische Berechnungen in Bash
WHO=/usr/bin/who # Zeigt eingeloggte Benutzer an
WC=/usr/bin/wc   # Zählt Wörter, Zeilen, Zeichen.
GREP=/bin/grep   # Zum Filtern von Textmustern
DATE=/bin/date   # Gibt Datum und Uhrzeit zurück
DF=/bin/df       # Zeigt Festplattennutzung an
CAT=/bin/cat     # Zum Ausgeben von Datei-Inhalten

# Konfigurationsdatei
# Diese Datei enthält die Benutzerdefinierten Einstellungen welche ich difiniert habe.
CONFIG="/home/marco/system-monitor/config.cfg"

# Log- und Report-Dateien
LOGFILE="/home/marco/system-monitor/system_monitor.log"
REPORT="/home/marco/system-monitor/system_warning_$($DATE '+%Y-%m-%d_%H-%M').log"

# Config laden (Überprüft, ob diese Datei existiert)
if [[ ! -e "$CONFIG" ]]; then # Prüft, ob die Konfigurationsdatei existiert
  echo "$($DATE): Achtung: Datei "$CONFIG" fehlt!" >> "$LOGFILE"
  exit 1  # Skript beenden, wenn keine Config gefunden wurde
fi

. "$CONFIG" # Lädt die Konfigurationsdatei (enthält Grenzwerte etc.)

# Systemwerte ermitteln
# CPU-Auslastung: Erster Wert aus /proc/loadavg zeigt 1-Minuten-Last an
CPU_USAGE=$($CAT /proc/loadavg | awk '{print $1}')
# Ermittelt den aktuell verwendeten Arbeitsspeicher (in MB) und speichert ihn in MEMORY_USAGE
MEMORY_USAGE=$(free -m | awk '/Mem:/ {print $3}')
# Angemeldeten Benutzer
USERS=$(who | wc -l)
# Fehlgeschlagene Loginversuche (letzte 5 Minuten)
TIME_STR=$(date --date='5 minutes ago' '+%b %_d %H:%M')
FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log 2>/dev/null | grep "$TIME_STR" | wc -l)
# WLAN0
if [ -e /sys/class/net/wlan0/operstate ]; then
# Wenn WLAN0 vorhanden ist, Status (up/down) auslesen
  WLAN0_STATUS=$(cat /sys/class/net/wlan0/operstate)
else
# Wenn kein WLAN0 = unknown
  WLAN0_STATUS="unknown"
fi
# ETH0
# Prüfen, ob das Netzwerkinterface eth0 existiert
if [ -e /sys/class/net/eth0/operstate ]; then
# Wenn ETHO vorhanden ist, Status (up/down) auslesen
  ETH0_STATUS=$(cat /sys/class/net/eth0/operstate)
else
# Wenn kein ETHO = unknown
  ETH0_STATUS="unknown"
fi
# Freier Speicherplatz
# Sucht freien Speicherplatz auf der Root-Partition (/)
# df zeigt Festplattenplatz, --output=avail gibt freien Platz in Kilobyte aus
# tail -1 zeigt die letzte Zeile an, damit die Überschrift nicht mitgenommen wird, sondern nur die Zahl.
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

# CPU Werte für Email
if (( $(echo "$CPU_USAGE > $CPU_WARN" | $BC -l) )); then
# Warnmeldung für CPU-Auslastung erstellen
  WARNUNG="ACHTUNG: Der RAM-Verbrauch hat das Limit von $CPU_WARN MB überschritten (aktuell: $CPU_USAGE MB)."
  echo "$WARNUNG" | tee -a "$REPORT" # tee -a schreibt die Ausgabe in die Datei und zeigt es im Terminal an.
  {
    echo "Subject: Warnung: CPU-Auslastung kritisch auf $(hostname)"
    echo "To: $WARNUNGS_EMAIL"
    echo
    echo "$WARNUNG am $($DATE)"
  } | /usr/bin/msmtp --from=default -t #Sendet den Text vor der Pipe (|) per E-Mail mit msmtp.--from=default benutzt das Standard-Absenderkonto.-t liest Empfänger, Betreff usw. aus dem E-Mail-Text.

# RAM Werte für Email
if (( $MEMORY_USAGE > $MEMORY_WARN )); then
# Warnmeldung für RAM-Auslastung erstellen
  WARNUNG="ACHTUNG: Der RAM-Verbrauch hat das Limit von $MEMORY_WARN MB überschritten (aktuell: $MEMORY_UAGE MB)."
  echo "$WARNUNG" | tee -a "$REPORT" #tee -a schreibt die Ausgabe in die Datei und zeigt es im Terminal an.
  {
    echo "Subject: Warnung: RAM-Verbrauch kritisch auf $(hostname)"
    echo "To: $WARNUNGS_EMAIL"
    echo
    echo "$WARNUNG am $($DATE)"
  } | /usr/bin/msmtp --from=default -t #Sendet den Text vor der Pipe (|) per E-Mail mit msmtp.--from=default benutzt das Standard-Absenderkonto.-t liest Empfänger, Betreff usw. aus dem E-Mail-Text.

# Skript-Ausführung
echo "$(date '+%Y-%m-%d %H:%M:%S') | CPU: $CPU_LOAD | RAM: $RAM_USED MB | Check abgeschlossen" >> "$LOGFILE"
# Schreibt eine Zeile mit aktuellem Datum, CPU- und RAM-Auslastung in die Logdatei
