# Giocate

App personale (installabile sul telefono) per tenere traccia di puntate, vincite e ricariche, mese per mese, con il riepilogo annuale.

- **Bilancio** = vincite − puntate. Le ricariche sono registrate e sommate a parte.
- **Dati**: salvati nel database Supabase `giocate-app` e in copia sul telefono, così l'app si apre e funziona anche senza rete. Le modifiche fatte offline vengono inviate appena torna internet.
- **Accesso**: niente account. Al primo avvio l'app chiede il codice di accesso, che non è scritto in questo repository. Senza codice il database non si legge e non si modifica.
- **Backup**: dal menu ⋯ puoi scaricare una copia in un file e ricaricarla (anche dal file Excel originale).

## File

- `index.html`: l'app.
- `config.js`: indirizzo del database e chiave pubblica.
- `schema.sql`: struttura del database (tabella e funzioni protette dal codice).
- `sw.js`, `manifest.webmanifest`, `icons/`: servono per installare l'app e aprirla offline.

## Cambiare il codice di accesso

In Supabase, progetto `giocate-app`, apri **SQL Editor** ed esegui (scegli tu il nuovo codice, in maiuscolo):

```sql
update giocate_private.chiave set hash = extensions.crypt('NUOVO-CODICE', extensions.gen_salt('bf', 10));
```

Sul telefono l'app chiederà di nuovo il codice.

## Cose da sapere

- Il piano gratuito di Supabase mette in pausa un progetto dopo un periodo senza utilizzo: i dati non si perdono, basta riattivarlo dalla dashboard di Supabase.
- Dopo aver aggiornato `index.html`, cambia il numero in `CACHE` dentro `sw.js` (es. `giocate-v3`) così il telefono scarica la nuova versione.
