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
