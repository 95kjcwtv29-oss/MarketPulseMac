# MarketPulseMac

Dashboard finanziaria in italiano per Mac mini M1: oro, futures petrolio WTI/Brent, cambio USD/JPY, notizie internazionali, mercati pertinenti di Polymarket e discussioni pubbliche.

## Importante: la preview web è solo statica

La pagina HTML aperta su servizi di preview online non può garantire l'accesso alle API finanziarie: il browser blocca alcune richieste cross-origin (CORS). Per i dati in diretta usa l'app locale, che effettua le richieste con un backend Python sul Mac.

## Installazione rapida sul Mac (senza allegati ChatGPT)

1. Apri Terminale sul Mac: premi `⌘ Spazio`, digita **Terminale**, premi Invio.
2. Incolla il comando seguente e premi Invio. Scarica il codice da questo repository, installa `~/Applications/MarketPulse.app` e apre la dashboard locale.

```bash
mkdir -p "$HOME/Downloads" && /usr/bin/curl -fL --retry 2 "https://github.com/95kjcwtv29-oss/MarketPulseMac/archive/refs/heads/main.zip" -o "$HOME/Downloads/MarketPulseMac.zip" && /usr/bin/ditto -x -k "$HOME/Downloads/MarketPulseMac.zip" "$HOME/Downloads" && /bin/bash "$HOME/Downloads/MarketPulseMac-main/mac-app/install-macos.sh"
```

La dashboard si apre su `http://127.0.0.1:8765`. Per avviarla in seguito, fai doppio clic su `~/Applications/MarketPulse.app`.

Per fermare il server:

```bash
/bin/bash "$HOME/Applications/Ferma-MarketPulse.command"
```

Se macOS mostra un avviso perché l'app non è firmata/notarizzata, non scegliere di ignorare eventuali avvisi generici alla cieca: verifica che l'archivio provenga dal repository ufficiale qui sopra; poi apri l'app con clic destro → **Apri** se macOS permette questa scelta.

L'app richiede Python 3 e non installa pacchetti Python esterni. Se Python 3 non è presente, installalo da https://www.python.org/downloads/macos/ e riesegui il comando.

## Funzionalità

- **Oro:** future COMEX `GC=F`, in USD/oncia troy (non oro fisico spot).
- **Petrolio WTI e Brent:** future `CL=F` e `BZ=F`, in USD/barile.
- **USD/JPY:** cambio indicativo.
- **Notizie:** ricerca RSS di Google News per oro, petrolio, yen e quadro macro.
- **Polymarket:** mercati attivi classificati per pertinenza diretta o proxy macro. Le probabilità non sono certezze.
- **Community:** Reddit RSS e tentativo di lettura di commenti pubblici; i risultati dipendono dalla disponibilità della piattaforma.
- **Investing.com:** collegamenti alle pagine originali dei commenti. Non viene effettuato scraping automatico dei contenuti protetti o soggetti a login.
- **Briefing AI facoltativo:** richiede una chiave API OpenAI e può comportare costi. La chiave viene inviata per la richiesta corrente, non è salvata dall'app.

## Agente locale per posizioni e notifiche macOS

La versione locale include un agente di sorveglianza in sola lettura: registri manualmente le posizioni aperte, imposti una soglia di movimento contrario per ogni posizione e una soglia globale per i movimenti dei riferimenti di mercato. L'agente può inviare notifiche macOS per movimenti oltre soglia e nuove notizie ad alto impatto pertinenti alle posizioni registrate. Offre anche una checklist contestuale di rischio, non segnali automatici di acquisto/vendita.

- Le posizioni sono salvate solo in `~/Library/Application Support/MarketPulse/agent_store.json`, con permessi locali limitati.
- Non chiede, legge o memorizza password, cookie o codici Plus500 e non invia ordini.
- Il conto Plus500 CFD retail non viene sincronizzato automaticamente: le posizioni vanno registrate e aggiornate manualmente.
- Il monitor usa quotazioni pubbliche di riferimento Yahoo Finance, non il Bid/Ask effettivo del conto Plus500. Gli avvisi sono indicativi e la scansione locale avviene ogni 5 minuti quando il Mac è sveglio e il server è in esecuzione.
- Per prezzi effettivi e alert broker in tempo reale, mantieni anche gli alert ufficiali Plus500: https://www.plus500.com/it/help/alerts.
- La documentazione pubblica di Plus500 che ho verificato descrive API .NET/FIX per la piattaforma T4 Futures, distinta dal conto CFD retail standard: https://pft.plus500.com/api.

Per aggiornare la copia installata, esegui in Terminale:

```bash
/usr/bin/curl -fLsS --retry 2 "https://raw.githubusercontent.com/95kjcwtv29-oss/MarketPulseMac/main/mac-app/aggiorna-macos.sh" -o "$HOME/Downloads/aggiorna-marketpulse.sh" && /bin/bash "$HOME/Downloads/aggiorna-marketpulse.sh"
```

## Fonti e limiti

- Yahoo Finance per quotazioni pubbliche potenzialmente ritardate.
- Google News RSS per titoli e collegamenti alle fonti.
- Gamma API pubblica di Polymarket per mercati previsionali.
- Reddit per discussioni pubbliche, se accessibili.
- I dati possono essere incompleti, ritardati o indisponibili. Il sentiment lessicale è solo indicativo. MarketPulse è informativo e non costituisce consulenza finanziaria.

## Diagnostica

Log locale: `~/Library/Logs/MarketPulse.log`.

Se l'app si apre ma i dati non arrivano, controlla il log. Puoi verificare che il backend locale risponda aprendo `http://127.0.0.1:8765/api/health` nel browser: deve mostrare `"ok": true`.
