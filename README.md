# Modul 122
## Checkpoint Linux Befehle

### Übung 1 - Repetition: Navigieren in Verzeichnissen

- cd ~
- cd /var/log
- cd /etc/udev
- cd ..
- cd newt
- cd ../../dev

![History aufgabe 1](History_Aufgabe_1.png)

### Übung 2 - Wildcards

- mkdir ~/Docs

- touch ~/Docs/file{1..10}

- rm ~/Docs/*1*

- rm ~/Docs/file{2,4,7}

- rm ~/Docs/*

- mkdir ~/Ordner

- touch ~/Ordner/file{1..10}

- cp -r ~/Ordner ~/Ordner2

- cp -r ~/Ordner ~/Ordner2/Ordner3

- mv ~/Ordner ~/Ordner1

- rm -r ~/Docs ~/Ordner1 ~/Ordner2

![History aufgabe 2](History_Aufgabe_2.png)

### Übung 3 - grep, cut (, awk)

cat << EOF > test.txt
alpha1:1alpha1:alp1ha
beta2:2beta:be2ta
gamma3:3gamma:gam3ma
obelix:belixo:xobeli
asterix:sterixa:xasteri
idefix:defixi:ixidef
EOF

![History aufgabe 3a](History_Aufgabe_3a.png)

grep --color=auto 'obelix' test.txt
grep --color=auto '2' test.txt
grep --color=auto 'e' test.txt
grep --color=auto -v 'gamma' test.txt
grep --color=auto -E '[123]' test.txt

![History aufgabe 3b](History_Aufgabe_3b.png)

cut -d':' -f1 test.txt
cut -d':' -f2 test.txt
cut -d':' -f3 test.txt

![History aufgabe 3c](History_Aufgabe_3c.png)

awk -F':' '{print $(NF-1)}' test.txt

![History aufgabe 3d](History_Aufgabe_3d.png)

### Übung 4 - Für Fortgeschrittene

dmesg | egrep '[0-9]{4}:[0-9]{2}:[0-9a-f]{2}.[0-9]'
Zeigt nur Zeilen aus dem Systemlog, in denen etwas wie eine Zeit oder Hex-Zahl vorkommt.

ifconfig | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'
Zeigt dir nur die IP-Adressen (z. B. 192.168.1.1) aus dem Netzwerkbefehl ifconfig.

![History aufgabe 4](History_Aufgabe_4.png)
### Übung 5 - stdout, stdin, stderr

cat << END > buchstaben.txt
a
b
c
d
e
END

![History aufgabe 5a](History_Aufgabe_5a.png)

ls -z 2> errorsLs.log

![History aufgabe 5b](History_Aufgabe_5b.png)

echo "Testinhalt" > testdatei.txt
cat testdatei.txt > neu.txt
cat testdatei.txt >> neu.txt
cat testdatei.txt >> neu.txt
cat neu.txt

![History aufgabe 5c](History_Aufgabe_5c.png)

whoami > info.txt

id >> info.txt

wc -w < info.txt

![History aufgabe 5d](History_Aufgabe_5d.png)
