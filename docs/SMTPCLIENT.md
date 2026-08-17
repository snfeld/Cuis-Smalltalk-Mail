# SmtpClient – SMTP-Client für Cuis 7.8

Dieser Client sendet E-Mails (auch mit Anhängen) über SMTP (RFC 5321) und funktioniert
mit jedem standardkonformen SMTP-Server — sowohl verschlüsselt über SMTPS
(Port 465, implizites TLS) als auch über Port 587 mit `STARTTLS`. Er ist als
Klasse `SmtpClient` im Package `Mail-SmtpClient` enthalten und läuft
vollständig headless ohne GUI. Das Package enthält außerdem die
Klassen `SmtpMessage` (Nachricht inkl. RFC-5322-Quelltext-Erzeugung) und
`SmtpAttachment` (einzelne Anhänge).

## Methoden-Kategorien

Die Methoden von `SmtpClient` sind nach Zweck gruppiert:

| Kategorie | Enthält |
|-----------|---------|
| `initialization` | `initialize` |
| `accessing` | `capabilities`, `state`, `stream`, `timeout`, `timeout:` |
| `connecting` | `close`, `connectToHost:`, `connectToHost:port:`, `establishConnectionWith:`, `quit`, `readGreeting`, `secureConnectToHost:port:`, `startTls` |
| `authentication` | `login:password:` |
| `sending` | `ehlo`, `parseCapabilities:`, `sendData:`, `sendMailFrom:to:subject:text:`, `sendMailFrom:to:subject:text:attachments:`, `sendMessage:` |
| `parsing` | `checkReply:`, `isPositiveReplyCode:`, `readReply`, `replyCode:`, `supportsAuthentication`, `supportsStartTls` |
| `testing` | `isConnected` |
| `private` | `base64Encode:`, `configureStream:`, `dotStuff:`, `localHostName`, `openSecureStreamToHost:port:`, `openStreamToHost:port:`, `readLine`, `replyText:`, `send:`, `sendCommand:` |

Namenskonvention: Parameter tragen Typ- und Zweck-Präfixe (`aString`, `aFromAddress`,
`aToAddresses`, `aPortNumber`).

## Voraussetzungen

Das Package benötigt `Network-Kernel` (für `SocketStream`) und `WebClient` (für `SecureSocketStream`).
Diese sind als `!requires:` im Package deklariert und werden automatisch geladen.

### Package laden

```smalltalk
Feature require: 'Mail-SmtpClient'.
```

Oder die `.pck.st`-Datei über den Cuis-Package-Installer laden.

## Schnellstart

```smalltalk
c := SmtpClient new.
c timeout: 10.                                     "Sicherheitsnetz: 10 s Timeout"
c secureConnectToHost: 'smtp.example.com' port: 465. "SMTPS (implizites TLS), Greeting + EHLO"
c login: 'benutzer@example.de' password: 'mein-passwort'.   "optional, falls der Server AUTH verlangt"
c sendMailFrom: 'benutzer@example.de'
    to: #('ziel@example.de')
    subject: 'Hallo'
    text: 'Eine Testnachricht'.
c quit.                                            "QUIT + Verbindung schließen"
```

Mit Anhang:

```smalltalk
c sendMailFrom: 'benutzer@example.de'
    to: #('ziel@example.de')
    subject: 'Rechnung'
    text: 'Im Anhang finden Sie die Rechnung.'
    attachments: {
        SmtpAttachment fileName: 'rechnung.pdf'
            contentType: 'application/pdf'
            content: (ByteArray readFrom: ...)}.
```

Alle Netzwerkoperationen sind blockierend, aber durch `timeout:` begrenzt — bei einem
nicht erreichbaren Server kommt eine Fehlermeldung statt eines Hängens.

## API-Referenz

### Verbindung aufbauen und schließen

| Methode | Beschreibung |
|---------|--------------|
| `connectToHost: aHostString` | Öffnet eine unverschlüsselte TCP-Verbindung auf den Standardport 25 und liest das Greeting. |
| `connectToHost: aHostString port: anInteger` | Wie oben, mit beliebigem Port (z. B. 587 für Submission). |
| `secureConnectToHost: aHostString port: anInteger` | Öffnet eine TLS-Verbindung (SMTPS, z. B. Port 465) und liest das Greeting. |
| `startTls` | Führt `STARTTLS` (RFC 3207) auf einer bestehenden unverschlüsselten Verbindung aus und verhandelt die Capabilities über TLS neu. |
| `quit` | Sendet `QUIT` (falls verbunden) und schließt dann die Verbindung. |
| `close` | Schließt die Verbindung ohne `QUIT`, setzt den Zustand auf `#disconnected`. |

**Wichtiges Server-Verhalten:** Manche Server senden die 220-Begrüßung auf
Port 465 erst, nachdem der Client Daten geschickt hat (die Begrüßung kann auch ganz
entfallen, sobald ein Befehl eingetroffen ist). `readGreeting` sendet deshalb EHLO
**vor** dem ersten Lesevorgang und behandelt beide Reihenfolgen (zuerst Greeting oder
direkt die EHLO-Antwort) korrekt — siehe [Intern (Helfer)](#intern-helfer).

### Konfiguration und Zustand

| Methode | Beschreibung |
|---------|--------------|
| `timeout` / `timeout: anInteger` | Netzwerk-Timeout in Sekunden (Default: `60`). Wirkt auf die nächste Verbindung. |
| `state` | Aktueller Zustand: `#disconnected`, `#connected` oder `#authenticated`. |
| `capabilities` | `OrderedCollection` der vom Server beworbenen EHLO-Capabilities (z. B. `'STARTTLS'`, `'SIZE 104857600'`, `'AUTH PLAIN LOGIN'`). |
| `stream` | Der zugrunde liegende `SocketStream` (zur Inspektion/Debug). |
| `isConnected` | Antwortet, ob eine Verbindung offen ist (`#connected`/`#authenticated`). |
| `supportsStartTls` | Antwortet, ob der Server `STARTTLS` bewirbt. |
| `supportsAuthentication` | Antwortet, ob der Server SMTP-Authentifizierung bewirbt (Capability beginnt mit `AUTH`). |
| `initialize` | Setzt `timeout := 60`, `state := #disconnected`, `hostName := nil`, `capabilities` leer. |

### Authentifizierung

| Methode | Beschreibung |
|---------|--------------|
| `login: aUserName password: aPassword` | Authentifiziert per `AUTH LOGIN` (Benutzer und Passwort Base64-kodiert). Bei Erfolg wird der Zustand `#authenticated`. Schlägt der Login fehl, wird ein Fehler geworfen (z. B. `SMTP 535: ... authentication failed`). |

### Senden

| Methode | Beschreibung |
|---------|--------------|
| `sendMailFrom: aFromAddress to: aToAddresses subject: aSubjectString text: aTextString` | Baut aus den Angaben eine `SmtpMessage` und sendet sie (Text-only). |
| `sendMailFrom: aFromAddress to: aToAddresses subject: aSubjectString text: aTextString attachments: anAttachmentCollection` | Wie oben, zusätzlich mit einer Collection von `SmtpAttachment` (multipart/mixed). |
| `sendMessage: anSmtpMessage` | Sendet eine vorgefertigte `SmtpMessage`: `MAIL FROM:<...>`, dann `RCPT TO:<...>` für jeden Empfänger (To **und** Cc), dann `DATA` und den dot-stuffed Quelltext. |

`aToAddresses` kann eine einzelne Adresse (String) oder eine Collection sein
(`normalizedCollection:`).

### Intern (Helfer)

| Methode | Beschreibung |
|---------|--------------|
| `send: aString` | Schreibt `aString` + CRLF auf den Stream und leert ihn. |
| `sendCommand: aString` | Sendet einen Befehl und liest die (Multi-Line-)Antwort. |
| `readReply` | Liest die Antwortzeilen, bis eine Zeile nicht mehr mit `nxx-` (Multi-Line) beginnt. Wirft einen Fehler, wenn die Verbindung zugeht. |
| `checkReply: aReplyLinesCollection` | Wirft einen `SMTP <code>: <text>`-Fehler, wenn der Antwortcode nicht 2xx/3xx ist; sonst Antwort der Zeilen. |
| `readGreeting` | Sendet EHLO und liest Greeting plus EHLO-Antwort. Manche Server (v. a. auf implizitem TLS/Port 465) senden das Greeting erst nach Client-Daten oder lassen es nach einem eingetroffenen Befehl ganz weg — beide Reihenfolgen werden behandelt. |
| `dotStuff: aString` | Normalisiert auf CRLF-Zeilenenden, verdoppelt führende Punkte am Zeilenanfang und hängt genau ein abschließendes CRLF an (RFC 5321 dot-stuffing). |
| `sendData: aMailSourceString` | Sendet den Nachrichtenquelltext in der `DATA`-Phase (dot-stuffed) plus dem abschließenden Punkt. |
| `base64Encode: aString` | Base64-Kodierung (für `AUTH LOGIN`). |
| `openStreamToHost:port:` / `openSecureStreamToHost:port:` | Öffnen des (TLS-)Socket-Streams inkl. Timeout-Konfiguration. |
| `configureStream: aSocketStream` | Setzt Textmodus und Timeout auf dem Stream. |

## SmtpMessage und SmtpAttachment

`SmtpMessage` erzeugt den RFC-5322-Quelltext und kennt zwei Layouts:

| Accessor / Methode | Beschreibung |
|----------|-----------|
| `from`, `to`, `cc` / `cc:`, `subject`, `text`, `date`, `attachments` | Felder der Nachricht. `date` ist `DateAndTime now` bei Erzeugung. |
| `recipients` | Alle Empfänger-Adressen (To plus Cc). |
| `rfc822Source` | Der komplette Quelltext mit CRLF-Zeilenenden, fertig für die `DATA`-Phase. Text-only → `plainSource`, sonst `multipartSource`. |
| `plainSource` | Text-only: `Content-Type: text/plain; charset=utf-8` mit `Content-Transfer-Encoding: quoted-printable`. |
| `multipartSource` | `multipart/mixed` mit einem UUID-Boundary (`CuismailBoundary…`); Text-Teil Quoted-Printable, Anhänge Base64 mit `Content-Disposition: attachment`. |
| `headerFields` | Basis-Header (`From`, `To`, `Date`, `Subject`, optional `Cc`, `MIME-Version`). Nicht-ASCII-Felder werden RFC-2047-kodiert (`=?UTF-8?B?...?=`). |

Klassen-Methoden: `SmtpMessage from: aFromAddress to: aToAddresses subject: aSubjectString text: aTextString`
und mit `attachments: anAttachmentCollection`.

`SmtpAttachment` erbt von `MailAttachment` und hat diese Accessors — alle stammen aus
der gemeinsamen Basisklasse `MailAttachment` (Paket `Mail-MailAttachment`), die sich
auch `ImapAttachment` teilt. Auch die Klassen-Methode
`SmtpAttachment fileName:contentType:content:` ist von `MailAttachment` geerbt:

| Accessor | Antwortet |
|----------|-----------|
| `fileName` | Dateiname (wird in `Content-Type: name=` und `Content-Disposition: filename=` gesetzt). |
| `contentType` | Content-Type des Teils, z. B. `'application/pdf'`. |
| `content` | Der Inhalt; bei binären Anhängen ein `ByteArray` (Base64-kodiert beim Versand). |

Erzeugung: `SmtpAttachment fileName: aString contentType: aString content: aByteArrayOrString`.

## Vollständiges Beispiel

```smalltalk
"Kompletter Lauf: verbinden (STARTTLS über 587), authentifizieren, Nachricht mit Anhang senden, abmelden"
| c |
c := SmtpClient new.
c timeout: 10.
c connectToHost: 'smtp.example.com' port: 587.
c startTls.                                      "Upgrade auf TLS + EHLO über TLS"
c login: 'benutzer@example.de' password: 'mein-passwort'.
c sendMailFrom: 'benutzer@example.de'
    to: #('ziel@example.de')
    subject: 'Grüße mit Anhang'
    text: 'Hallo, hier ist der Bericht.'
    attachments: {
        SmtpAttachment fileName: 'bericht.txt'
            contentType: 'text/plain'
            content: 'Inhalt des Berichts' asByteArray}.
c quit.
```

Hinweis: Der obige Login funktioniert nur mit echten Zugangsdaten. Ohne Login liefert der
Server saubere Fehler, die der Client unverändert durchreicht (siehe unten).

## Fehlerverhalten

- **Server-Ablehnung:** Bei nicht-positiven Antworten (nicht 2xx/3xx) wird eine
  `Error`-Exception mit dem Original-Text des Servers geworfen, z. B.:
  - `SMTP 535: 5.7.8 Authentication credentials invalid` (falscher Login)
  - `SMTP 554: 5.7.1 <...>: Relay access denied` (Relay ohne Berechtigung)
- **Timeout:** Ist der Server nicht erreichbar oder antwortet nicht, wird nach der
  eingestellten Zeit eine `ConnectionTimedOut`-Exception geworfen. Es hängt nichts.
- **Verbindungsabbruch:** Geht die Verbindung während einer Antwort zu, wird ein Fehler
  (`ConnectionClosed` bzw. `Error`) geworfen — kein Endlos-Warten.
- **Fehlerbehandlung im Test** (Muster für eigene Skripte — `on: Error do:` als letzte
  Anweisung des Ausdrucks):

```smalltalk
| c out |
out := WriteStream on: String new.
c := SmtpClient new.
c timeout: 10.
[out nextPutAll: (c secureConnectToHost: 'smtp.example.com' port: 465) class name,
        ' state=', c state printString] on: Error do: [:e |
    out nextPutAll: 'ERR ', e class name, ': ', e messageText].
out contents
```

## Tests

Der Client wird durch das Package **`Tests-SmtpClient`** abgesichert.
Es enthält 5 Testklassen (insgesamt **39 Tests**) plus das Fixture `SmtpMockStream`,
einen `SocketStream`-Ersatz für Offline-Tests.

| Klasse | Anzahl | Deckt ab |
|--------|-------:|----------|
| `SmtpClientStateTest` | 6 | `initialize`-Werte, `state`-Übergänge, `isConnected`, `capabilities` |
| `SmtpClientParsingTest` | 13 | `readReply` (einfach/multi-line, Fehler bei Verbindungsende), `checkReply:`, `replyCode:`, `isPositiveReplyCode:`, `dotStuff:` (CRLF, führende Punkte, leer) |
| `SmtpClientTest` | 6 | `ehlo`/Capabilities, `supportsStartTls`, `supportsAuthentication`, `sendCommand:`-Pfade, Fehlertexte |
| `SmtpClientSendingTest` | 4 | `sendMessage:`/`sendData:`-Ablauf gegen den Mock (MAIL FROM, RCPT TO, DATA, Dot-Stuffing, Quit) |
| `SmtpMessageTest` | 10 | `plainSource`/`multipartSource` (Header, Boundary, Teile), RFC-2822-Datum, RFC-2047-Encoding, Quoted-Printable |
| `SmtpMockStream` (Fixture) | – | Beantwortet Befehle mit vorbereiteten Antwortzeilen; zählt gesendete Zeilen |

Alle Tests sind Offline-Tests (mit `SmtpMockStream`), kein Netzwerkzugang erforderlich.

## Einschränkungen

- Nur die **`AUTH LOGIN`**-Authentifizierung (kein OAuth, kein `AUTH PLAIN`/`CRAM-MD5`).
- Es wird **EHLO** vorausgesetzt (kein automatischer Fallback auf `HELO`). Gegen
  aktuelle Server ist das unproblematisch.
- Nachrichten werden synchron gesendet (ein Thread, blockierend mit Timeout).
- Kein Empfangen von E-Mails — dafür siehe das Package `Mail-ImapClient` (`ImapClient`).
