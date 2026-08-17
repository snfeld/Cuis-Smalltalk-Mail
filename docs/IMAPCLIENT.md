# ImapClient – IMAP-Client für Cuis 7.8

Dieser Client spricht IMAP4rev1 (RFC 3501) über TCP (Port 143) oder TLS/IMAPS
(Port 993) und funktioniert mit jedem standardkonformen IMAP-Server.
Er ist als Klasse `ImapClient` im Package `Mail-ImapClient` enthalten
(55 Methoden in 11 Kategorien) und läuft vollständig headless ohne GUI.
Das Package enthält außerdem die Klassen `ImapMessage` (geparste
Nachrichtenstruktur) und `ImapAttachment` (einzelne Anhänge) für die
strukturierte Nachrichtenabfrage (`fetchMessageStructure:`).
`ImapAttachment` erbt die Basis-Attachment-Daten (`fileName`, `contentType`, `content`)
von `MailAttachment` aus dem Paket `Mail-MailAttachment` (gemeinsam genutzt mit
`SmtpAttachment` aus `Mail-SmtpClient`).

## Methoden-Kategorien

Die Methoden sind nach Zweck gruppiert:

| Kategorie | Enthält |
|-----------|---------|
| `accessing` | `capabilities`, `mailbox`, `state`, `stream`, `timeout`, `timeout:` |
| `connecting` | `connectToHost:`, `connectToHost:port:`, `secureConnectToHost:port:`, `close`, `logout`, `readGreeting` |
| `authentication` | `login:password:` |
| `mailboxes` | `listMailboxes`, `selectMailbox:`, `numberOfMessagesIn:` |
| `message fetching` | `fetch:using:`, `fetchMessage:`, `fetchMessageHeader:`, `fetchMessagesFrom:to:`, `fetchMessageStructure:` |
| `message management` | `deleteMessage:`, `expunge`, `moveMessage:toMailbox:` |
| `mailbox management` | `createMailbox:`, `renameMailbox:toMailbox:`, `deleteMailbox:` |
| `parsing` | `capabilityTokensFromLine:`, `checkStatus:`, `isContinuationRequest:`, `isListLine:`, `isTaggedLine:forTag:`, `isUntaggedLine:`, `literalSizeFromLine:`, `mailboxNameFromListLine:`, `messageCountFromStatusLine:`, `quoteArg:`, `sequenceNumberFromExpungeLine:`, `tokensIn:`, `unquote:` |
| `testing` | `isConnected`, `supportsMove` |
| `initialization` | `initialize` |
| `private` | `configureStream:`, `fetchCapabilities`, `nextTag`, `openSecureStreamToHost:port:`, `openStreamToHost:port:`, `readFetchLine:forTag:into:`, `readLine`, `readLiteralIfPresentIn:`, `readResponseLine:forTag:into:`, `send:`, `sendCommand:` |

Namenskonvention: Parameter tragen Typ- und Zweck-Präfixe (`anInteger`, `aString`, `aHostString`, `aStartNumber`).

## Voraussetzungen

Das Package benötigt `Network-Kernel` (für `SocketStream`) und `WebClient` (für `SecureSocketStream`).
Diese sind als `!requires:` im Package deklariert und werden automatisch geladen.

### Package laden

```smalltalk
Feature require: 'Mail-ImapClient'.
```

Oder die `.pck.st`-Datei über den Cuis-Package-Installer laden.

## Schnellstart

```smalltalk
c := ImapClient new.
c timeout: 10.                                   "Sicherheitsnetz: 10 s Timeout"
c secureConnectToHost: 'imap.example.com' port: 993.   "IMAPS, liest das Greeting"
c login: 'benutzer@example.de' password: 'mein-passwort'.
c listMailboxes.                                 "→ OrderedCollection aller Ordner"
c selectMailbox: 'INBOX'.
c fetchMessageHeader: 1.                         "→ Header der 1. Nachricht"
c fetchMessage: 1.                               "→ komplette RFC822-Nachricht (Rohdaten)"
c fetchMessageStructure: 1.                      "→ geparste ImapMessage (Header, Body, Anhänge)"
c logout.                                        "LOGOUT + Verbindung schließen"
```

Alle Netzwerkoperationen sind blockierend, aber durch `timeout:` begrenzt —
bei einem nicht erreichbaren Server kommt eine Fehlermeldung statt eines Hängens
(siehe [Fehlerverhalten](#fehlerverhalten)).

## API-Referenz

### Verbindung aufbauen und schließen

| Methode | Beschreibung |
|---------|--------------|
| `connectToHost: aHostString` | Öffnet eine unverschlüsselte TCP-Verbindung auf Port 143 und liest das Greeting. |
| `connectToHost: aHostString port: anInteger` | Wie oben, mit beliebigem Port. |
| `secureConnectToHost: aHostString port: anInteger` | Öffnet eine TLS-Verbindung (z. B. Port 993 für IMAPS) und liest das Greeting. Nach dem Greeting werden automatisch die Server-Capabilities abgefragt (`capabilities`). |
| `close` | Schließt die Verbindung, setzt den Zustand auf `#disconnected`. |
| `logout` | Sendet `LOGOUT` (falls verbunden) und schließt dann die Verbindung. |

### Konfiguration und Zustand

| Methode | Beschreibung |
|---------|--------------|
| `timeout` / `timeout: anInteger` | Netzwerk-Timeout in Sekunden (Default: `60`). Wirkt auf die nächste Verbindung. |
| `state` | Aktueller Zustand: `#disconnected`, `#connected` oder `#authenticated`. |
| `mailbox` | Die aktuell ausgewählte Mailbox, sonst `nil`. |
| `capabilities` | `OrderedCollection` der vom Server beworbenen Capabilities (z. B. `'IMAP4rev1'`, `'MOVE'`, `'UIDPLUS'`). Wird beim Verbinden automatisch gefüllt. |
| `supportsMove` | Antwortet, ob der Server den `MOVE`-Befehl (RFC 6851) unterstützt. |
| `stream` | Der zugrunde liegende `SocketStream` (zur Inspektion/Debug). |
| `isConnected` | Antwortet, ob eine Verbindung offen ist (`#connected`/`#authenticated`). |
| `initialize` | Setzt `tagCounter := 0`, `timeout := 60`, `state := #disconnected`, `mailbox := nil`, `capabilities` leer. |

### Authentifizierung

| Methode | Beschreibung |
|---------|--------------|
| `login: aUserName password: aPassword` | Sendet `LOGIN` (Argumente werden korrekt quotiert). Bei Erfolg wird der Zustand `#authenticated`. Schlägt der Login fehl, wird ein Fehler geworfen (z. B. `IMAP NO: ... AUTHENTICATIONFAILED`). |

### Mailboxen

| Methode | Beschreibung |
|---------|--------------|
| `listMailboxes` | Antwortet eine `OrderedCollection` aller Mailbox-Namen über `LIST "" "*"`. |
| `selectMailbox: aString` | Wählt eine Mailbox (`SELECT`); nachfolgende `fetch*`-Aufrufe adressieren Nachrichten in ihr. |
| `numberOfMessagesIn: aMailboxName` | Antwortet die Anzahl der Nachrichten in einer Mailbox über `STATUS <name> (MESSAGES)` – ohne die Mailbox auszuwählen. Eine leere Mailbox antwortet `0`. |

### Nachrichten abrufen

| Methode | Beschreibung |
|---------|--------------|
| `fetchMessage: anInteger` | Holt die komplette Nachricht (`BODY[]`) und antwortet den Quelltext als `String`. |
| `fetchMessageHeader: anInteger` | Holt nur den RFC822-Header (`BODY[HEADER]`). |
| `fetch: anInteger using: aString` | Generisch; `aString` ist z. B. `'BODY[]'`, `'BODY[HEADER]'` oder `'BODY[TEXT]'`. Literale (`{n}`) werden automatisch eingelesen. |
| `fetchMessagesFrom: aStartNumber to: anEndNumber` | Holt einen Sequenznummern-Bereich; antwortet eine `OrderedCollection` von Nachrichtenquellen. |
| `fetchMessageStructure: aSequenceNumber` | Holt die komplette Nachricht (`BODY[]`) und antwortet sie als **geparste `ImapMessage`** (siehe unten). |

### Nachrichten verwalten (löschen, verschieben)

| Methode | Beschreibung |
|---------|--------------|
| `deleteMessage: aSequenceNumber` | Markiert die Nachricht in der ausgewählten Mailbox als gelöscht (`STORE <n> +FLAGS.SILENT (\Deleted)`). Die Nachricht wird erst durch `expunge` physisch entfernt. |
| `expunge` | Entfernt alle mit `\Deleted` markierten Nachrichten aus der ausgewählten Mailbox. Antwortet eine `OrderedCollection` der entfernten Sequenznummern (leer, wenn keine entfernt wurden). |
| `moveMessage: aSequenceNumber toMailbox: aMailboxName` | Verschiebt die Nachricht in eine andere Mailbox. Nutzt `MOVE` (RFC 6851), wenn der Server es unterstützt (`supportsMove`); sonst `COPY` + `\Deleted` + `expunge` als Fallback. |

Beispiel:

```smalltalk
| c |
c := ImapClient new.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'benutzer@example.de' password: 'mein-passwort'.
c selectMailbox: 'INBOX'.
c moveMessage: 1 toMailbox: 'Trash'.   "Nachricht 1 in den Papierkorb verschieben"
c deleteMessage: 2.                    "Nachricht 2 als gelöscht markieren"
c expunge.                             "gelöschte Nachrichten physisch entfernen"
c logout.
```

Hinweis: Nach `expunge` bzw. `moveMessage:` verschieben sich die Sequenznummern der
verbleibenden Nachrichten.

### Mailboxen verwalten (anlegen, verschieben, löschen)

| Methode | Beschreibung |
|---------|--------------|
| `createMailbox: aMailboxName` | Legt eine neue Mailbox mit dem angegebenen Namen an (`CREATE`, RFC 3501). Antwortet den angelegten Namen. |
| `renameMailbox: aMailboxName toMailbox: aNewMailboxName` | Benennt die Mailbox um (`RENAME`, RFC 3501). Ein Verschieben in einen anderen Ordner erfolgt über den vollständigen Zielnamen inkl. Ziel-Parent (z. B. `'Archiv/Projekte'`). Antwortet den neuen Namen. |
| `deleteMailbox: aMailboxName` | Löscht die Mailbox (`DELETE`, RFC 3501). Antwortet den gelöschten Namen. |

Beispiel:

```smalltalk
| c |
c := ImapClient new.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'benutzer@example.de' password: 'mein-passwort'.
c createMailbox: 'Projekte'.                "neuer Ordner auf oberster Ebene"
c createMailbox: 'Projekte/Planung'.        "neuer Unterordner"
c renameMailbox: 'Projekte' toMailbox: 'Archiv/Projekte'.   "nach Archiv verschieben"
c deleteMailbox: 'Projekte/Planung'.        "Unterordner löschen"
c logout.
```

Hinweis: Das Löschen einer Mailbox mit Unterordnern oder mit der Markierung
`\Noselect` kann der Server ablehnen; der `NO`/`BAD`-Text des Servers wird als
Fehler durchgereicht (siehe [Fehlerverhalten](#fehlerverhalten)).

### Nachrichtenstruktur (ImapMessage / ImapAttachment)

`fetchMessageStructure:` zerlegt die RFC822-Quelle in eine `ImapMessage`:

| Accessor | Antwortet |
|----------|-----------|
| `subject` | Betreff, RFC-2047-dekodiert (Base64/Quoted-Printable). |
| `from` | Absender (dekodiert). |
| `to` | Empfänger (dekodiert). |
| `date` | Datum (dekodiert). |
| `header` | Der rohe RFC822-Header als `String`. |
| `body` | Der dekodierte Textinhalt. Bei `multipart/*` die verketteten Texte aller Text-Teile (ohne Anhänge). |
| `attachments` | Eine `OrderedCollection` von `ImapAttachment` (leer, wenn es keine gibt). |

Als Anhang gilt ein Teil, der nicht mit `text/` beginnt, oder ein Text-Teil mit
`Content-Disposition: attachment`. Anhang-Teile erscheinen **nicht** in `body`.

`ImapAttachment` erbt von `MailAttachment` und hat diese Accessors — `fileName`,
`contentType` und `content` stammen aus der gemeinsamen Basisklasse `MailAttachment`
(Paket `Mail-MailAttachment`), die sich auch `SmtpAttachment` teilt:

| Accessor | Antwortet |
|----------|-----------|
| `fileName` | Dateiname (aus `Content-Disposition: filename=` oder `Content-Type: name=`; Fallback `'attachment'`). |
| `contentType` | Content-Type des Teils. |
| `content` | Der Inhalt – bei Base64/QP dekodiert; Binäranhänge als `ByteArray`. |
| `disposition` | Der rohe `Content-Disposition`-Wert, sonst `nil`. |

Beispiel:

```smalltalk
|c msg|
c := ImapClient new.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'benutzer@example.de' password: 'mein-passwort'.
c selectMailbox: 'INBOX'.
msg := c fetchMessageStructure: 1.
{msg subject. msg body size. msg attachments size}   "z. B. {'Grüße'. 42. 1}"
msg attachments first fileName                        "z. B. 'rechnung.pdf'"
c logout.
```

### Intern (Helfer)

| Methode | Beschreibung |
|---------|--------------|
| `nextTag` | Nächster Tag (`a1`, `a2`, …) für die Befehle. |
| `send: aString` | Schreibt `aString` + CRLF auf den Stream und leert ihn. |
| `sendCommand: aString` | Sendet einen Befehls-Tag und wartet auf die getaggte Antwort. Antwortet eine `OrderedCollection` der untagged Zeilen; wirft bei `NO`/`BAD` einen Fehler. Bei untagged Literalen (`* ... {n}`) wird der Literalinhalt mit eingelesen. |
| `readLine` | Liest eine CRLF-terminierte Zeile. |
| `readGreeting` | Liest die Server-Begrüßung. Manche Server senden das Greeting erst nach dem ersten Befehl — ein `NOOP` löst das ab (funktioniert auch bei Servern, die sofort antworten). |
| `quoteArg: aString` | Quotiert ein Argument für IMAP (Backslash und Anführungszeichen werden escaped). |
| `unquote: aString` | Entfernt umschließende doppelte Anführungszeichen. |
| `tokensIn: aString` | Tokenisiert eine Zeile in eine `OrderedCollection` (respektiert doppelte Anführungszeichen). |
| `literalSizeFromLine: aLine` | Antwortet die Literalgröße, wenn die Zeile auf `{n}` endet, sonst `nil`. |
| `mailboxNameFromListLine: aLine` | Extrahiert den Mailbox-Namen aus einer `* LIST ...`-Zeile. |
| `messageCountFromStatusLine: aLine` | Extrahiert die Nachrichtenanzahl aus einer `* STATUS ... (MESSAGES n)`-Zeile; `nil` bei Nicht-STATUS-Zeilen. |
| `capabilityTokensFromLine: aLine` | Antwortet die Capability-Tokens aus einer `* CAPABILITY ...`-Zeile als `OrderedCollection`, sonst leer. |
| `sequenceNumberFromExpungeLine: aLine` | Antwortet die Sequenznummer aus einer `* n EXPUNGE`-Zeile, sonst `nil`. |
| `checkStatus: aTaggedLine` | Prüft die Statuszeile; wirft `IMAP NO:`/`IMAP BAD:`-Fehler entsprechend. |
| `isUntaggedLine: aLine` | Antwortet, ob die Zeile eine untagged Antwort ist (beginnt mit `*`). |
| `isContinuationRequest: aLine` | Antwortet, ob die Zeile eine Continuation-Anfrage ist (beginnt mit `+`). |
| `isTaggedLine: aLine forTag: aTag` | Antwortet, ob die Zeile die getaggte Antwort für `aTag` ist. |
| `isListLine: aLine` | Antwortet, ob die Zeile eine `* LIST ...`-Zeile ist. |
| `readLiteralIfPresentIn: aLine` | Antwortet die Zeile, ggf. ergänzt um den Literalinhalt (`{n}`). |
| `readResponseLine:forTag:into:` | Verarbeitet eine Antwortzeile im `sendCommand:`-Kontext (Sammeln von untagged Zeilen, Ignorieren von `+`/leeren Zeilen, Fehler bei Unerwartetem). |
| `readFetchLine:forTag:into:` | Verarbeitet eine Antwortzeile im `fetch:`-Kontext (Literalinhalt an den Ergebnis-Stream anhängen). |
| `openStreamToHost:port:` / `openSecureStreamToHost:port:` | Öffnen des (TLS-)Socket-Streams inkl. Timeout-Konfiguration. |
| `configureStream: aSocketStream` | Setzt Textmodus und Timeout auf dem Stream. |
| `fetchCapabilities` | Fragt die Server-Capabilities ab (`CAPABILITY`), füllt `capabilities` und antwortet sie. Wird beim Verbinden automatisch aufgerufen. |

## Vollständiges Beispiel

```smalltalk
"Kompletter Lauf: verbinden, anmelden, Mailboxen, Nachricht laden, abmelden"
| c folders msg |
c := ImapClient new.
c timeout: 10.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'benutzer@example.de' password: 'mein-passwort'.
folders := c listMailboxes.
c selectMailbox: 'INBOX'.
'/tmp/nachricht1.txt' asFileEntry writeStreamDo: [:s |
    s nextPutAll: (c fetchMessage: 1)].
msg := c fetchMessageStructure: 1.
msg attachments ifNotEmpty: [
    msg attachments first content
        ifNotNil: [:bytes |
            '/tmp/anhang.bin' asFileEntry writeStreamDo: [:s | s nextPutAll: bytes]]].
c logout.
{folders size. c state. msg subject}
```

Hinweis: Der obige Login funktioniert nur mit echten Zugangsdaten. Ohne Login liefert der
Server saubere Fehler, die der Client unverändert durchreicht (siehe unten).

## Fehlerverhalten

- **Server-Ablehnung:** Bei `NO`/`BAD`-Antworten wird eine `Error`-Exception mit dem
  Original-Text des Servers geworfen, z. B.:
  - `IMAP NO: a3 NO [AUTHENTICATIONFAILED] x Authentication failed` (falscher Login)
  - `IMAP BAD: a2 BAD [CLIENTBUG] Please login first` (LIST/Login-Befehle ohne Login)
- **Timeout:** Ist der Server nicht erreichbar oder antwortet nicht, wird nach der
  eingestellten Zeit eine `ConnectionTimedOut`-Exception geworfen. Es hängt nichts.
- **Fehlerbehandlung im Test** (Muster für eigene Skripte — `on: Error do:` als letzte
  Anweisung des Ausdrucks):

```smalltalk
| c out |
out := WriteStream on: String new.
c := ImapClient new.
c timeout: 10.
[out nextPutAll: (c secureConnectToHost: 'imap.example.com' port: 993) class name,
        ' state=', c state printString] on: Error do: [:e |
    out nextPutAll: 'ERR ', e class name, ': ', e messageText].
out contents
```

## Tests

Der Client wird durch das Package **`Tests-ImapClient`** abgesichert.
Es enthält 9 Testklassen (insgesamt **110 Tests**) plus das Fixture `ImapMockStream`,
einen `SocketStream`-Ersatz für Offline-Tests.

| Klasse | Anzahl | Deckt ab |
|--------|-------:|----------|
| `ImapClientStateTest` | 6 | `initialize`-Werte, `state`-Übergänge, `isConnected`, `mailbox` |
| `ImapClientParsingTest` | 23 | `tokensIn:` (inkl. Quoting/Leerzeichen), `unquote:`, `quoteArg:`, `literalSizeFromLine:`, `mailboxNameFromListLine:`, `isListLine:`, `checkStatus:` (OK/NO/BAD), `isTaggedLine:` |
| `ImapClientTest` | 20 | `nextTag`, `sendCommand:`-Helfer (untagged/Continuation/Listen), `numberOfMessagesIn:` und `messageCountFromStatusLine:` (inkl. leerer Mailbox) |
| `ImapClientProtocolTest` | 16 | `sendCommand:` gegen den Mock (Tag, Literale, untagged Antworten, NO/BAD-Fehler) |
| `ImapClientFetchTest` | 15 | `fetch:using:`-Pfade (Header/Text/BODY[]), Literal-Einlesen, Antwortzeilen-Stacking, `fetchMessageStructure:` |
| `ImapClientMailboxesTest` | 3 | `selectMailbox:` (OK/NO), `mailbox`-Zustand |
| `ImapClientMessageManagementTest` | 11 | `fetchCapabilities`, `capabilityTokensFromLine:`, `supportsMove`, `deleteMessage:`, `expunge`, `moveMessage:toMailbox:` (MOVE und Fallback) |
| `ImapClientMailboxManagementTest` | 7 | `createMailbox:` (inkl. Quoting von Namen mit Leerzeichen), `renameMailbox:toMailbox:` (inkl. Verschieben in einen Parent-Ordner), `deleteMailbox:`, Befehlsfolge auf einem Client, `NO`-Ablehnung |
| `ImapMessageTest` | 9 | `ImapMessage`/`ImapAttachment`: Plain-Text, RFC-2047-Subject, Base64/QP-Body, Multipart mit Anhängen, verschachtelte Anhänge, Boundary mit Folgeparametern |
| `ImapMockStream` (Fixture) | – | Beantwortet IMAP-Literale (`{n}`) mehrfach hintereinander |

Alle Tests sind Offline-Tests (mit `ImapMockStream`), kein Netzwerkzugang erforderlich.

## Einschränkungen

- Nur der **LOGIN**-Mechanismus (kein SASL/OAuth, kein `AUTHENTICATE PLAIN`).
- Keine Befehle wie `IDLE`, `SEARCH`, UID-basierte Zugriffe oder beliebige Flag-Operationen —
  die Basis (`sendCommand:`) ist aber erweiterbar und reicht jedes IMAP-Kommando durch.
  `deleteMessage:`/`expunge`/`moveMessage:toMailbox:` sind die eingebauten
  Nachrichten-Operationen (sequenzbasiert).
- `fetchMessage:`, `fetchMessageHeader:` und `fetchMessagesFrom:to:` liefern **Rohdaten**.
  Für strukturierten Zugriff gibt es `fetchMessageStructure:` (Base64/Quoted-Printable und
  RFC-2047 werden dekodiert; HTML-Teile werden nicht extrahiert, verschachtelte
  `multipart/mixed`-Innenteile werden rekursiv behandelt).
- Sequenznummern statt UIDs; nach `expunge`/`moveMessage:` verschieben sich die Nummern
  der verbleibenden Nachrichten — vor dem Weiterarbeiten aktuelle Nummern erneut holen.
- Mailbox-Verwaltung (`createMailbox:`/`renameMailbox:toMailbox:`/`deleteMailbox:`)
  deckt die RFC-3501-Befehle ab; UTF-7/UTF-8-kodierte Namen werden unverändert
  durchgereicht, und ein `NO`/`BAD` des Servers (z. B. beim Löschen eines nicht-leeren
  Ordners) wird als Fehler mit Servertext geworfen.
- Alle Operationen sind synchron (ein Thread, blockierend mit Timeout).
