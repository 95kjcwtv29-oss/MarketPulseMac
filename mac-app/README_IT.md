# MarketPulse — dashboard finanziaria locale per Mac mini M1

**Prima versione funzionante, per macOS 11 o successivo.** L'interfaccia è una dashboard locale che si apre nel browser predefinito. Non richiede `pip`, librerie Python esterne, un database o un account per vedere i dati gratuiti.

## Avvio

1. Scarica ed estrai `MarketPulseMac.zip` in una cartella del Mac, per esempio Applicazioni o Documenti.
2. Apri `MarketPulse.app` con un doppio clic. Al primo avvio macOS potrebbe bloccare l'app perché non è firmata/notarizzata: fai clic destro sull'app, scegli **Apri** e conferma.
3. Si aprirà il browser all'indirizzo `http://127.0.0.1:8765`. Il server rimane locale al Mac e non viene esposto in rete.
4. Per avviare dalla cartella senza usare il bundle, fai doppio clic su `Avvia-MarketPulse.command`.
5. Per fermare il server, fai doppio clic su `Ferma-MarketPulse.command`.

Se macOS blocca anche i file `.command`, fai clic destro su `Avvia-MarketPulse.command` e scegli **Apri**. È necessario avere `python3` disponibile nel Terminale. Tutto il codice usa esclusivamente la libreria standard di Python.

## Cosa include

- **Oro:** future COMEX `GC=F` (USD/oncia troy), non oro spot fisico.
- **Petrolio WTI e Brent:** future `CL=F` e `BZ=F` (USD/barile).
- **USD/JPY:** cambio indicativo da Yahoo Finance.
- **Notizie internazionali:** feed RSS di Google News per oro, petrolio, USD/JPY e quadro macro.
- **Polymarket:** ricerca di mercati attivi tramite l'API pubblica Gamma. I match diretti sono separati da quelli macro indiretti, come decisioni Fed/BoJ.
- **Commenti e discussioni pubbliche:** ricerca RSS su Reddit e tentativo di recupero dei commenti con più voti nelle discussioni pertinenti; se Reddit limita le richieste, la dashboard mostra i thread come ripiego. I risultati dipendono dalle limitazioni del feed.
- **Investing.com:** pulsanti per aprire direttamente le pagine dei commenti di oro, petrolio e USD/JPY. Il sito non offre una API pubblica ufficiale, perciò questa prima versione non copia automaticamente i suoi commenti.
- **Sintesi automatica:** briefing euristico basato sui dati effettivamente ricevuti. Le etichette di sentiment sono semplici analisi lessicali, non un modello finanziario validato.
- **Sintesi AI facoltativa:** si può inserire una chiave API OpenAI nella dashboard per produrre un briefing più articolato. La richiesta usa `gpt-6-luna`; la chiave non è salvata dal programma. L'uso dell'API può comportare addebiti sul tuo account OpenAI API. Non è necessaria per il funzionamento base.

## Fonti e limiti importanti

- **Prezzi:** Yahoo Finance (`query1.finance.yahoo.com`), con possibili ritardi e indisponibilità. Le variazioni confrontano il prezzo restituito con la chiusura precedente disponibile.
- **Notizie:** Google News RSS; il titolo e il link conducono all'editore, quando disponibile.
- **Mercati predittivi:** Gamma API di Polymarket (`gamma-api.polymarket.com`). Le probabilità riflettono prezzi di mercato e non probabilità oggettive certe. L'assenza di un match viene mostrata esplicitamente.
- **Community:** Reddit RSS può limitare richieste o non fornire estratti; un post non equivale a un commento verificato e il campione non è rappresentativo.
- **Sintesi:** non vengono eseguiti ordini e non è presente una funzione di trading. Questa dashboard è informativa, non consulenza finanziaria.

## Aggiornamento e risoluzione problemi

Il pulsante **Aggiorna ora** forza una nuova lettura delle fonti. I dati vengono messi in cache per circa 2 minuti e mezzo tra un aggiornamento e l'altro. Se i feed online non rispondono, alcune sezioni possono essere vuote senza che l'app sia guasta.

Log locale: `~/Library/Logs/MarketPulse.log`.

Se la porta locale `8765` è occupata da un altro programma, chiudi quel programma oppure modifica `PORT` in `marketpulse.py` e la porta `8765` in `MarketPulse.app/Contents/MacOS/MarketPulse` e negli script `.command`.