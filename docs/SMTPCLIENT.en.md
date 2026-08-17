# SmtpClient – SMTP client for Cuis 7.8

This client sends e-mail (including attachments) over SMTP (RFC 5321) and works
with any standard SMTP server — both via SMTPS (port 465, implicit TLS)
and via port 587 with `STARTTLS`. It is available as the class `SmtpClient` in the
package `Mail-SmtpClient` and runs fully headless without a GUI. The
package also contains the classes `SmtpMessage` (a message including RFC 5322 source
generation) and `SmtpAttachment` (individual attachments).

## Method categories

The methods of `SmtpClient` are grouped by purpose:

| Category | Contains |
|----------|----------|
| `initialization` | `initialize` |
| `accessing` | `capabilities`, `state`, `stream`, `timeout`, `timeout:` |
| `connecting` | `close`, `connectToHost:`, `connectToHost:port:`, `establishConnectionWith:`, `quit`, `readGreeting`, `secureConnectToHost:port:`, `startTls` |
| `authentication` | `login:password:` |
| `sending` | `ehlo`, `parseCapabilities:`, `sendData:`, `sendMailFrom:to:subject:text:`, `sendMailFrom:to:subject:text:attachments:`, `sendMessage:` |
| `parsing` | `checkReply:`, `isPositiveReplyCode:`, `readReply`, `replyCode:`, `supportsAuthentication`, `supportsStartTls` |
| `testing` | `isConnected` |
| `private` | `base64Encode:`, `configureStream:`, `dotStuff:`, `localHostName`, `openSecureStreamToHost:port:`, `openStreamToHost:port:`, `readLine`, `replyText:`, `send:`, `sendCommand:` |

Naming convention: parameters carry type/purpose prefixes (`aString`, `aFromAddress`,
`aToAddresses`, `aPortNumber`).

## Prerequisites

The package requires `Network-Kernel` (for `SocketStream`) and `WebClient` (for `SecureSocketStream`).
These are declared as `!requires:` in the package and loaded automatically.

### Loading the package

```smalltalk
Feature require: 'Mail-SmtpClient'.
```

Or load the `.pck.st` file via the Cuis package installer.

## Quick start

```smalltalk
c := SmtpClient new.
c timeout: 10.                                     "safety net: 10 s timeout"
c secureConnectToHost: 'smtp.example.com' port: 465. "SMTPS (implicit TLS), greeting + EHLO"
c login: 'user@example.com' password: 'my-password'.   "optional, if the server requires AUTH"
c sendMailFrom: 'user@example.com'
    to: #('recipient@example.com')
    subject: 'Hello'
    text: 'A test message'.
c quit.                                            "QUIT + close connection"
```

With an attachment:

```smalltalk
c sendMailFrom: 'user@example.com'
    to: #('recipient@example.com')
    subject: 'Invoice'
    text: 'Please find the invoice attached.'
    attachments: {
        SmtpAttachment fileName: 'invoice.pdf'
            contentType: 'application/pdf'
            content: (ByteArray readFrom: ...)}.
```

All network operations are blocking, but bounded by `timeout:` — an unreachable server
produces an error message instead of hanging.

## API reference

### Connecting and disconnecting

| Method | Description |
|--------|-------------|
| `connectToHost: aHostString` | Opens a plain TCP connection on the default port 25 and reads the greeting. |
| `connectToHost: aHostString port: anInteger` | As above, with an arbitrary port (e.g. 587 for submission). |
| `secureConnectToHost: aHostString port: anInteger` | Opens a TLS connection (SMTPS, e.g. port 465) and reads the greeting. |
| `startTls` | Runs `STARTTLS` (RFC 3207) on an existing plain connection and re-negotiates capabilities over TLS. |
| `quit` | Sends `QUIT` (if connected) and then closes the connection. |
| `close` | Closes the connection without `QUIT`, setting state to `#disconnected`. |

**Important server behaviour:** Some servers only send the 220 greeting on
port 465 after the client has sent data (and may skip it entirely once a command has
arrived). `readGreeting` therefore sends EHLO **before** the first read and handles both
orders (greeting first, or the EHLO response directly) — see
[Helpers (internal)](#helpers-internal).

### Configuration and state

| Method | Description |
|--------|-------------|
| `timeout` / `timeout: anInteger` | Network timeout in seconds (default: `60`). Applies to the next connection. |
| `state` | Current state: `#disconnected`, `#connected` or `#authenticated`. |
| `capabilities` | `OrderedCollection` of the EHLO capabilities advertised by the server (e.g. `'STARTTLS'`, `'SIZE 104857600'`, `'AUTH PLAIN LOGIN'`). |
| `stream` | The underlying `SocketStream` (for inspection/debugging). |
| `isConnected` | Answers whether a connection is open (`#connected`/`#authenticated`). |
| `supportsStartTls` | Answers whether the server advertises `STARTTLS`. |
| `supportsAuthentication` | Answers whether the server advertises SMTP authentication (capability starting with `AUTH`). |
| `initialize` | Sets `timeout := 60`, `state := #disconnected`, `hostName := nil`, `capabilities` empty. |

### Authentication

| Method | Description |
|--------|-------------|
| `login: aUserName password: aPassword` | Authenticates via `AUTH LOGIN` (user name and password Base64-encoded). On success the state becomes `#authenticated`. If the login fails, an error is raised (e.g. `SMTP 535: ... authentication failed`). |

### Sending

| Method | Description |
|--------|-------------|
| `sendMailFrom: aFromAddress to: aToAddresses subject: aSubjectString text: aTextString` | Builds an `SmtpMessage` from the arguments and sends it (text only). |
| `sendMailFrom: aFromAddress to: aToAddresses subject: aSubjectString text: aTextString attachments: anAttachmentCollection` | As above, plus a collection of `SmtpAttachment` (multipart/mixed). |
| `sendMessage: anSmtpMessage` | Sends a pre-built `SmtpMessage`: `MAIL FROM:<...>`, then `RCPT TO:<...>` for every recipient (To **and** Cc), then `DATA` and the dot-stuffed source. |

`aToAddresses` may be a single address (String) or a collection
(`normalizedCollection:`).

### Helpers (internal)

| Method | Description |
|--------|-------------|
| `send: aString` | Writes `aString` + CRLF to the stream and flushes it. |
| `sendCommand: aString` | Sends a command and reads the (multi-line) reply. |
| `readReply` | Reads reply lines until a line no longer starts with `nxx-` (multi-line). Raises an error when the connection goes away. |
| `checkReply: aReplyLinesCollection` | Raises an `SMTP <code>: <text>` error when the reply code is not 2xx/3xx; otherwise answers the reply lines. |
| `readGreeting` | Sends EHLO and reads the greeting plus the EHLO response. Some servers (especially on implicit TLS port 465) send the greeting only after client data, or omit it once a command arrived — both orders are handled. |
| `dotStuff: aString` | Normalizes to CRLF line endings, doubles leading dots at line starts, and appends exactly one trailing CRLF (RFC 5321 dot-stuffing). |
| `sendData: aMailSourceString` | Sends the message source in the `DATA` phase (dot-stuffed) plus the terminating dot. |
| `base64Encode: aString` | Base64 encoding (used for `AUTH LOGIN`). |
| `openStreamToHost:port:` / `openSecureStreamToHost:port:` | Open the (TLS) socket stream including timeout configuration. |
| `configureStream: aSocketStream` | Sets text mode and the timeout on the stream. |

## SmtpMessage and SmtpAttachment

`SmtpMessage` generates the RFC 5322 source and knows two layouts:

| Accessor / method | Description |
|-------------------|-------------|
| `from`, `to`, `cc` / `cc:`, `subject`, `text`, `date`, `attachments` | Message fields. `date` is `DateAndTime now` at creation. |
| `recipients` | All recipient addresses (To plus Cc). |
| `rfc822Source` | The complete source with CRLF line endings, ready for the `DATA` phase. Text-only → `plainSource`, otherwise `multipartSource`. |
| `plainSource` | Text-only: `Content-Type: text/plain; charset=utf-8` with `Content-Transfer-Encoding: quoted-printable`. |
| `multipartSource` | `multipart/mixed` with a UUID boundary (`CuismailBoundary…`); the text part is quoted-printable, attachments Base64 with `Content-Disposition: attachment`. |
| `headerFields` | Base header (`From`, `To`, `Date`, `Subject`, optional `Cc`, `MIME-Version`). Non-ASCII fields are RFC 2047 encoded (`=?UTF-8?B?...?=`). |

Class methods: `SmtpMessage from: aFromAddress to: aToAddresses subject: aSubjectString text: aTextString`
and with `attachments: anAttachmentCollection`.

`SmtpAttachment` inherits from `MailAttachment` and has these accessors — all of them come
from the shared base class `MailAttachment` (package `Mail-MailAttachment`), also used by
`ImapAttachment`. The class method `SmtpAttachment fileName:contentType:content:` is
inherited from `MailAttachment` too:

| Accessor | Answers |
|----------|---------|
| `fileName` | File name (used in `Content-Type: name=` and `Content-Disposition: filename=`). |
| `contentType` | Content type of the part, e.g. `'application/pdf'`. |
| `content` | The content; a `ByteArray` for binary attachments (Base64-encoded on send). |

Creation: `SmtpAttachment fileName: aString contentType: aString content: aByteArrayOrString`.

## Complete example

```smalltalk
"Full run: connect (STARTTLS over 587), authenticate, send a message with an attachment, quit"
| c |
c := SmtpClient new.
c timeout: 10.
c connectToHost: 'smtp.example.com' port: 587.
c startTls.                                      "upgrade to TLS + EHLO over TLS"
c login: 'user@example.com' password: 'my-password'.
c sendMailFrom: 'user@example.com'
    to: #('recipient@example.com')
    subject: 'Greetings with attachment'
    text: 'Hello, here is the report.'
    attachments: {
        SmtpAttachment fileName: 'report.txt'
            contentType: 'text/plain'
            content: 'Report contents' asByteArray}.
c quit.
```

Note: The login above only works with real credentials. Without a login the server
delivers clean errors that the client passes through unchanged (see below).

## Error handling

- **Server rejection:** For non-positive replies (not 2xx/3xx) an `Error` exception is
  raised with the server's original text, e.g.:
  - `SMTP 535: 5.7.8 Authentication credentials invalid` (wrong login)
  - `SMTP 554: 5.7.1 <...>: Relay access denied` (relaying without permission)
- **Timeout:** If the server is unreachable or does not answer, a `ConnectionTimedOut`
  exception is raised after the configured time. Nothing hangs.
- **Connection drop:** If the connection closes during a reply, an error
  (`ConnectionClosed` or `Error`) is raised — no endless waiting.
- **Error handling in a test** (pattern for your own scripts — `on: Error do:` as the
  last statement of the expression):

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

The client is covered by the package **`Tests-SmtpClient`**.
It contains 5 test classes (in total **39 tests**) plus the fixture `SmtpMockStream`,
a `SocketStream` replacement for offline tests.

| Class | Count | Covers |
|-------|------:|--------|
| `SmtpClientStateTest` | 6 | `initialize` values, `state` transitions, `isConnected`, `capabilities` |
| `SmtpClientParsingTest` | 13 | `readReply` (simple/multi-line, error on connection close), `checkReply:`, `replyCode:`, `isPositiveReplyCode:`, `dotStuff:` (CRLF, leading dots, empty) |
| `SmtpClientTest` | 6 | `ehlo`/capabilities, `supportsStartTls`, `supportsAuthentication`, `sendCommand:` paths, error texts |
| `SmtpClientSendingTest` | 4 | `sendMessage:`/`sendData:` flow against the mock (MAIL FROM, RCPT TO, DATA, dot-stuffing, quit) |
| `SmtpMessageTest` | 10 | `plainSource`/`multipartSource` (headers, boundary, parts), RFC 2822 date, RFC 2047 encoding, quoted-printable |
| `SmtpMockStream` (fixture) | – | Answers commands with prepared reply lines; counts sent lines |

All tests are offline (using `SmtpMockStream`), no network access required.

## Limitations

- Only **`AUTH LOGIN`** authentication (no OAuth, no `AUTH PLAIN`/`CRAM-MD5`).
- **EHLO** is assumed (no automatic fallback to `HELO`). Against current servers
  this is unproblematic.
- Messages are sent synchronously (one thread, blocking with a timeout).
- No receiving of e-mail — for that see the `Mail-ImapClient` package (`ImapClient`).
