# Projekt: System-Monitoring & Alarm bei Überlastung

## Tag 1: 27.06.2025

Am ersten Tag haben wir uns überlegt, was für ein Projekt wir machen wollen, und uns dann für System-Monitoring mit Alarmierung entschieden. Danach haben wir eine Anforderungsliste gemacht und ein UML-Diagramm erstellt (muss noch angepasst werden).

## Tag 2: 04.07.2025

Heute haben wir uns um den Code gekümmert. Der läuft jetzt automatisch über einen Cronjob, und wenn ein Alarm ausgelöst wird, wird eine Mail verschickt. Dafür haben wir einen MSMTP-Server eingerichtet, der die Mails an unsere Adresse schickt.
