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
