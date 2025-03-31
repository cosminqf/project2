
# PackageMonitor

## Introducere

PackageMonitor își propune să simplifice monitorizarea pachetelor software instalate sau eliminate pe un sistem Linux. 

Prin procesarea log-urilor generate de sistem, utilizatorul poate accesa informații importante despre pachete, fără a parcurge manual log-urile.

Pe un sistem Linux, operatiile precum instalarea și eliminarea pachetelor sunt înregistrate în fișiere precum `/var/log/dpkg.log`. Deși aceste log-uri sunt utile, ele nu sunt ușor de citit sau de organizat. 

---

## Design

Soluția este împărțită în două componente:

1. **Monitorul (`monitor.sh`)**:
   
- Procesorul principal de log-uri. Citește direct din `/var/log/dpkg.log`, extrage operațiunile `install` și `remove`, și salvează datele în directorul `./data/`. 
- Fiecare pachet software primește un folder propriu, istoricul este păstrat în fișiere `history.log`.

2. **Front-end-ul (`frontend.sh`)**:
- Interfața utilizatorului care oferă mai multe funcții pentru accesarea datelor. Afișează pachetele instalate, eliminate sau toate operațiunile dintr-un interval specificat.

---

## Implementare și folosire

### Monitorul (`monitor.sh`)

Cum functioneaza:
- Citește fiecare linie din `/var/log/dpkg.log`.
- Verifică dacă linia conține operațiuni relevante (`install` sau `remove`).
- Organizează datele în subdirectoare corespunzătoare fiecărui package, salvând doar liniile noi pentru a evita duplicarea.

Pentru a permite rularea, utilizatorul trebuie să seteze permisiunile scriptului astfel:
```bash
chmod +x monitor.sh frontend.sh
```

Pentru rularea periodică automată, utilizatorul poate configura un cron job. Exemplu pentru a rula `monitor.sh` la fiecare minut:
```bash
crontab -e
```
Adaugă următoarea linie:
```bash
* * * * * /path/to/monitor.sh
```

### Front-end-ul (`frontend.sh`)

Utilizatorul poate executa diverse comenzi:

#### Lista pachetelor instalate

```bash
./frontend.sh list-installed
```

**Exemplu rezultat:**
```
pachet1 - 2025-01-15 19:45:47 install
pachet2 - 2025-01-16 08:23:14 install
```

#### Lista pachetelor eliminate

```bash
./frontend.sh list-removed
```

**Exemplu rezultat:**
```
pachet1 - 2025-01-15 20:47:59 remove
pachet3 - 2025-01-16 09:12:31 remove
```

#### Istoricul unui pachet

```bash
./frontend.sh history <nume_pachet>
```

**Exemplu:**
```bash
./frontend.sh history pachet1
```

**Rezultat:**
```
2025-01-15 19:45:47 install
2025-01-15 20:47:59 remove
2025-01-16 08:23:14 install
```

#### Operatiuni dintr-un interval de timp

```bash
./frontend.sh list-timeframe <start_date> <end_date>
```

**Exemplu:**
```bash
./frontend.sh list-timeframe 2025-01-15 2025-01-16
```

**Rezultat:**
```
pachet1 - 2025-01-15 19:45:47 install
pachet2 - 2025-01-16 08:23:14 install
pachet1 - 2025-01-15 20:47:59 remove
```

---

## Cod Relevant

### Exemplu de cod pentru verificarea pachetelor instalate:

```bash
list_installed() {
    echo "Pachete instalate si data ultimei instalari:"
    
    for pkg in "$WORK_DIR"/*; do
        if [ -d "$pkg" ]; then
            LAST_ACTION=$(tail -n 1 "$pkg/history.log" | awk '{print $3}')

            if [ "$LAST_ACTION" == "install" ]; then
                LAST_INSTALL=$(grep "install" "$pkg/history.log" | tail -n 1)
                echo "$(basename "$pkg") - $LAST_INSTALL"
            fi
        fi
    done
}
```

---

## Concluzii

Proiectul oferă o soluție eficientă pentru gestionarea istoricului pachetelor sistemului, transformând log-urile în date ușor accesibile. Cu ajutorul monitorului și frontend-ului, utilizatorii pot obține rapid informații relevante despre starea pachetelor lor software. 

Deși funcțional, proiectul poate fi îmbunătățit prin integrarea unui UI sau extinderea funcționalităților pentru alte tipuri de log-uri.
