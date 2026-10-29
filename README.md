# MarketPulseMac

Dashboard web in italiano per seguire oro, petrolio WTI/Brent, USD/JPY, notizie finanziarie e mercati previsionali di Polymarket.

## Apri la dashboard online

Dopo che GitHub Pages ha completato la prima pubblicazione:
https://95kjcwtv29-oss.github.io/MarketPulseMac/

La pubblicazione è automatizzata dal workflow `.github/workflows/pages.yml`. Se GitHub segnala che Pages non è ancora configurato, apri **Settings → Pages** nel repository e imposta **Build and deployment → Source: GitHub Actions**. Poi esegui nuovamente il workflow da **Actions**.

## Dati e limiti

- Prezzi: futures oro (`GC=F`), WTI (`CL=F`), Brent (`BZ=F`) e USD/JPY (`USDJPY=X`) richiesti tramite endpoint pubblico Yahoo Finance. Possono non essere disponibili da ogni browser per limiti CORS o del servizio.
- Notizie: feed RSS interrogati tramite RSS2JSON; il servizio terzo può limitare richieste o non restituire alcuni feed.
- Polymarket: mercati attivi ricercati tramite API pubblica Gamma; un mercato macro (es. decisione Fed/BoJ) è solo una proxy e non è una previsione diretta dell'asset.
- Community: i collegamenti aprono le discussioni pubbliche di Investing.com e Reddit. Investing.com può richiedere login e non viene sottoposto a scraping automatizzato.

La pagina mostra un avviso quando una fonte non è raggiungibile. I dati possono essere ritardati o incompleti; non è consulenza finanziaria.

## Uso locale

Puoi aprire `index.html` in un browser, ma le API cross-origin possono essere limitate. La versione locale con backend Python può essere aggiunta separatamente; GitHub Pages serve solo pagine statiche.


## Installa MarketPulse.app sul Mac (senza allegati ChatGPT)

Apri **Terminale** sul Mac, incolla il comando seguente e premi Invio. Scarica i sorgenti direttamente da GitHub, crea `~/Applications/MarketPulse.app` e prova ad aprirla. L'app apre la dashboard locale nel browser su `http://127.0.0.1:8765`.

```bash
mkdir -p "$HOME/Downloads" && /usr/bin/curl -fL --retry 2 "https://github.com/95kjcwtv29-oss/MarketPulseMac/archive/refs/heads/main.zip" -o "$HOME/Downloads/MarketPulseMac.zip" && /usr/bin/ditto -x -k "$HOME/Downloads/MarketPulseMac.zip" "$HOME/Downloads" && /bin/bash "$HOME/Downloads/MarketPulseMac-main/mac-app/install-macos.sh"
```

Per avviare in seguito, fai doppio clic su `~/Applications/MarketPulse.app`. Se macOS lo blocca perché non è firmato/notarizzato, fai clic destro sull'app e scegli **Apri**. Per fermare il server, esegui:

```bash
/bin/bash "$HOME/Applications/Ferma-MarketPulse.command"
```

L'installazione richiede Python 3. Se non è presente, l'installatore mostra il messaggio con il link per installarlo.

Il programma usa Python 3 e la libreria standard. Se il comando segnala che Python 3 non è disponibile, va installato prima di avviare l'app. La prima apertura di eventuali file scaricati può mostrare gli avvisi di sicurezza macOS.

## Anteprima rapida della dashboard web

La dashboard statica può essere visualizzata senza download tramite il servizio esterno [HTML Preview](https://html-preview.github.io/?url=https://github.com/95kjcwtv29-oss/MarketPulseMac/blob/main/index.html). È una preview di terze parti e non sostituisce la versione locale completa.
