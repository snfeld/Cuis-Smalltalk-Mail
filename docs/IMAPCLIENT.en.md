# ImapClient – IMAP client for Cuis 7.8

This client speaks IMAP4rev1 (RFC 3501) over TCP (port 143) or TLS/IMAPS
(port 993) and works with any standard IMAP server.
It ships as the class `ImapClient` in the package `Mail-ImapClient`
(55 methods in 11 categories) and runs fully headless without a GUI.
The package also contains the classes `ImapMessage` (parsed message
structure) and `ImapAttachment` (a single attachment) for structured
message fetching (`fetchMessageStructure:`).
`ImapAttachment` inherits the base attachment data (`fileName`, `contentType`, `content`)
from `MailAttachment` (package `Mail-MailAttachment`), shared with
`SmtpAttachment` in `Mail-SmtpClient`.

## Method categories

The methods are grouped by purpose:

| Category | Contains |
|----------|----------|
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

Naming convention: parameters carry type and purpose prefixes (`anInteger`, `aString`, `aHostString`, `aStartNumber`).

## Prerequisites

The package requires `Network-Kernel` (for `SocketStream`) and `WebClient` (for `SecureSocketStream`).
These are declared as `!requires:` in the package and loaded automatically.

### Loading the package

```smalltalk
Feature require: 'Mail-ImapClient'.
```

Or load the `.pck.st` file via the Cuis package installer.

## Quick start

```smalltalk
c := ImapClient new.
c timeout: 10.                                   "safety net: 10 s timeout"
c secureConnectToHost: 'imap.example.com' port: 993.   "IMAPS, reads the greeting"
c login: 'user@example.com' password: 'my-password'.
c listMailboxes.                                 "→ OrderedCollection of all folders"
c selectMailbox: 'INBOX'.
c fetchMessageHeader: 1.                         "→ header of message 1"
c fetchMessage: 1.                               "→ complete RFC822 message (raw)"
c fetchMessageStructure: 1.                      "→ parsed ImapMessage (header, body, attachments)"
c logout.                                        "LOGOUT + close the connection"
```

All network operations are blocking but bounded by `timeout:` — when the server is
unreachable you get an error instead of a hang (see [Error behavior](#error-behavior)).

## API reference

### Connecting and closing

| Method | Description |
|--------|-------------|
| `connectToHost: aHostString` | Opens an unencrypted TCP connection on port 143 and reads the greeting. |
| `connectToHost: aHostString port: anInteger` | As above, with an arbitrary port. |
| `secureConnectToHost: aHostString port: anInteger` | Opens a TLS connection (e.g. port 993 for IMAPS) and reads the greeting. After the greeting the server capabilities are queried automatically (`capabilities`). |
| `close` | Closes the connection and sets the state to `#disconnected`. |
| `logout` | Sends `LOGOUT` (if connected) and then closes the connection. |

### Configuration and state

| Method | Description |
|--------|-------------|
| `timeout` / `timeout: anInteger` | Network timeout in seconds (default: `60`). Applies to the next connection. |
| `state` | Current state: `#disconnected`, `#connected` or `#authenticated`. |
| `mailbox` | The currently selected mailbox, otherwise `nil`. |
| `capabilities` | `OrderedCollection` of the capabilities advertised by the server (e.g. `'IMAP4rev1'`, `'MOVE'`, `'UIDPLUS'`). Filled automatically on connect. |
| `supportsMove` | Answers whether the server supports the `MOVE` command (RFC 6851). |
| `stream` | The underlying `SocketStream` (for inspection/debugging). |
| `isConnected` | Answers whether a connection is open (`#connected`/`#authenticated`). |
| `initialize` | Sets `tagCounter := 0`, `timeout := 60`, `state := #disconnected`, `mailbox := nil`, `capabilities` empty. |

### Authentication

| Method | Description |
|--------|-------------|
| `login: aUserName password: aPassword` | Sends `LOGIN` (arguments are quoted correctly). On success the state becomes `#authenticated`. If the login fails, an error is raised (e.g. `IMAP NO: ... AUTHENTICATIONFAILED`). |

### Mailboxes

| Method | Description |
|--------|-------------|
| `listMailboxes` | Answers an `OrderedCollection` of all mailbox names via `LIST "" "*"`. |
| `selectMailbox: aString` | Selects a mailbox (`SELECT`); subsequent `fetch*` calls address messages in it. |
| `numberOfMessagesIn: aMailboxName` | Answers the number of messages in a mailbox via `STATUS <name> (MESSAGES)` — without selecting the mailbox. An empty mailbox answers `0`. |

### Fetching messages

| Method | Description |
|--------|-------------|
| `fetchMessage: anInteger` | Fetches the complete message (`BODY[]`) and answers the raw source as a `String`. |
| `fetchMessageHeader: anInteger` | Fetches only the RFC822 header (`BODY[HEADER]`). |
| `fetch: anInteger using: aString` | Generic; `aString` is e.g. `'BODY[]'`, `'BODY[HEADER]'` or `'BODY[TEXT]'`. Literals (`{n}`) are read automatically. |
| `fetchMessagesFrom: aStartNumber to: anEndNumber` | Fetches a sequence-number range; answers an `OrderedCollection` of message sources. |
| `fetchMessageStructure: aSequenceNumber` | Fetches the complete message (`BODY[]`) and answers it as a **parsed `ImapMessage`** (see below). |

### Managing messages (delete, move)

| Method | Description |
|--------|-------------|
| `deleteMessage: aSequenceNumber` | Marks the message in the selected mailbox as deleted (`STORE <n> +FLAGS.SILENT (\Deleted)`). The message is removed physically only by `expunge`. |
| `expunge` | Removes all messages marked `\Deleted` from the selected mailbox. Answers an `OrderedCollection` of the sequence numbers that were removed (empty if none). |
| `moveMessage: aSequenceNumber toMailbox: aMailboxName` | Moves the message to another mailbox. Uses `MOVE` (RFC 6851) when the server supports it (`supportsMove`); otherwise falls back to `COPY` + `\Deleted` + `expunge`. |

Example:

```smalltalk
| c |
c := ImapClient new.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'user@example.com' password: 'my-password'.
c selectMailbox: 'INBOX'.
c moveMessage: 1 toMailbox: 'Trash'.   "move message 1 to the trash"
c deleteMessage: 2.                    "mark message 2 as deleted"
c expunge.                             "physically remove deleted messages"
c logout.
```

Note: after `expunge` or `moveMessage:`, the sequence numbers of the remaining
messages shift.

### Managing mailboxes (create, rename, delete)

| Method | Description |
|--------|-------------|
| `createMailbox: aMailboxName` | Creates a new mailbox with the given name (`CREATE`, RFC 3501). Answer the created mailbox name. |
| `renameMailbox: aMailboxName toMailbox: aNewMailboxName` | Renames the mailbox (`RENAME`, RFC 3501). Moving a mailbox into another folder is done by giving a full target name that includes the target parent (e.g. `'Archive/Projects'`). Answer the new mailbox name. |
| `deleteMailbox: aMailboxName` | Deletes the mailbox (`DELETE`, RFC 3501). Answer the deleted mailbox name. |

Example:

```smalltalk
| c |
c := ImapClient new.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'user@example.com' password: 'my-password'.
c createMailbox: 'Projects'.                "new top-level folder"
c createMailbox: 'Projects/Planning'.       "new sub-folder"
c renameMailbox: 'Projects' toMailbox: 'Archive/Projects'.   "move into Archive"
c deleteMailbox: 'Projects/Planning'.       "delete the sub-folder"
c logout.
```

Note: deleting a mailbox with sub-mailboxes or marked as `\Noselect` may be
rejected by the server; the server's `NO`/`BAD` text is passed through as an
error (see "Error behavior").

### Message structure (ImapMessage / ImapAttachment)

`fetchMessageStructure:` splits the RFC822 source into an `ImapMessage`:

| Accessor | Answers |
|----------|---------|
| `subject` | Subject, RFC-2047-decoded (base64/quoted-printable). |
| `from` | Sender (decoded). |
| `to` | Recipient (decoded). |
| `date` | Date (decoded). |
| `header` | The raw RFC822 header as a `String`. |
| `body` | The decoded text content. For `multipart/*`, the concatenated texts of all text parts (without attachments). |
| `attachments` | An `OrderedCollection` of `ImapAttachment` (empty when there are none). |

A part counts as an attachment when it does not start with `text/`, or when a text
part is explicitly marked with `Content-Disposition: attachment`. Attachment parts
do **not** appear in `body`.

`ImapAttachment` inherits from `MailAttachment` and has these accessors — `fileName`,
`contentType` and `content` come from the shared base class `MailAttachment`
(package `Mail-MailAttachment`), also used by `SmtpAttachment`:

| Accessor | Answers |
|----------|---------|
| `fileName` | The file name (from `Content-Disposition: filename=` or `Content-Type: name=`; fallback `'attachment'`). |
| `contentType` | The Content-Type of the part. |
| `content` | The content — decoded for base64/QP; binary attachments come back as a `ByteArray`. |
| `disposition` | The raw `Content-Disposition` value, otherwise `nil`. |

Example:

```smalltalk
|c msg|
c := ImapClient new.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'user@example.com' password: 'my-password'.
c selectMailbox: 'INBOX'.
msg := c fetchMessageStructure: 1.
{msg subject. msg body size. msg attachments size}   "e.g. {'Greetings'. 42. 1}"
msg attachments first fileName                        "e.g. 'invoice.pdf'"
c logout.
```

### Internals (helpers)

| Method | Description |
|--------|-------------|
| `nextTag` | Next tag (`a1`, `a2`, …) for commands. |
| `send: aString` | Writes `aString` + CRLF to the stream and flushes it. |
| `sendCommand: aString` | Sends a command tag and waits for the tagged reply. Answers an `OrderedCollection` of the untagged lines; raises an error on `NO`/`BAD`. Untagged literals (`* ... {n}`) have their literal content read in. |
| `readLine` | Reads a CRLF-terminated line. |
| `readGreeting` | Reads the server greeting. Some servers send the greeting only after the first command — a `NOOP` triggers it (also works for servers that answer immediately). |
| `quoteArg: aString` | Quotes an argument for IMAP (backslash and double quotes are escaped). |
| `unquote: aString` | Removes surrounding double quotes. |
| `tokensIn: aString` | Tokenizes a line into an `OrderedCollection` (respects double quotes). |
| `literalSizeFromLine: aLine` | Answers the literal size if the line ends in `{n}`, otherwise `nil`. |
| `mailboxNameFromListLine: aLine` | Extracts the mailbox name from a `* LIST ...` line. |
| `messageCountFromStatusLine: aLine` | Extracts the message count from a `* STATUS ... (MESSAGES n)` line; `nil` for non-STATUS lines. |
| `capabilityTokensFromLine: aLine` | Answers the capability tokens of a `* CAPABILITY ...` line as an `OrderedCollection`, or empty for other lines. |
| `sequenceNumberFromExpungeLine: aLine` | Answers the sequence number of a `* n EXPUNGE` line, otherwise `nil`. |
| `checkStatus: aTaggedLine` | Checks the status line; raises `IMAP NO:`/`IMAP BAD:` errors accordingly. |
| `isUntaggedLine: aLine` | Answers whether the line is an untagged reply (starts with `*`). |
| `isContinuationRequest: aLine` | Answers whether the line is a continuation request (starts with `+`). |
| `isTaggedLine: aLine forTag: aTag` | Answers whether the line is the tagged reply for `aTag`. |
| `isListLine: aLine` | Answers whether the line is a `* LIST ...` line. |
| `readLiteralIfPresentIn: aLine` | Answers the line, extended with the literal content (`{n}`) if present. |
| `readResponseLine:forTag:into:` | Processes a reply line in the `sendCommand:` context (collects untagged lines, ignores `+`/empty lines, errors on unexpected input). |
| `readFetchLine:forTag:into:` | Processes a reply line in the `fetch:` context (appends literal content to the result stream). |
| `openStreamToHost:port:` / `openSecureStreamToHost:port:` | Open the (TLS) socket stream including timeout configuration. |
| `configureStream: aSocketStream` | Sets text mode and timeout on the stream. |
| `fetchCapabilities` | Queries the server capabilities (`CAPABILITY`), fills `capabilities` and answers them. Called automatically on connect. |

## Complete example

```smalltalk
"Full run: connect, log in, list mailboxes, load a message, log out"
| c folders msg |
c := ImapClient new.
c timeout: 10.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'user@example.com' password: 'my-password'.
folders := c listMailboxes.
c selectMailbox: 'INBOX'.
'/tmp/message1.txt' asFileEntry writeStreamDo: [:s |
    s nextPutAll: (c fetchMessage: 1)].
msg := c fetchMessageStructure: 1.
msg attachments ifNotEmpty: [
    msg attachments first content
        ifNotNil: [:bytes |
            '/tmp/attachment.bin' asFileEntry writeStreamDo: [:s | s nextPutAll: bytes]]].
c logout.
{folders size. c state. msg subject}
```

Note: The login above only works with real credentials. Without login the server
returns clean errors that the client passes through unchanged (see below).

## Error behavior

- **Server rejection:** On `NO`/`BAD` replies an `Error` exception is raised carrying the
  server's original text, e.g.:
  - `IMAP NO: a3 NO [AUTHENTICATIONFAILED] x Authentication failed` (wrong login)
  - `IMAP BAD: a2 BAD [CLIENTBUG] Please login first` (LIST/login commands without login)
- **Timeout:** If the server is unreachable or does not answer, a `ConnectionTimedOut`
  exception is raised after the configured time. Nothing hangs.
- **Error handling in a test** (pattern for your own scripts — `on: Error do:` as the last
  statement of the expression):

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

The client is covered by the package **`Tests-ImapClient`**. It contains
9 test classes (a total of **110 tests**) plus the fixture `ImapMockStream`, a
`SocketStream` stand-in for offline tests.

| Class | Count | Covers |
|-------|------:|--------|
| `ImapClientStateTest` | 6 | `initialize` values, `state` transitions, `isConnected`, `mailbox` |
| `ImapClientParsingTest` | 23 | `tokensIn:` (incl. quoting/spaces), `unquote:`, `quoteArg:`, `literalSizeFromLine:`, `mailboxNameFromListLine:`, `isListLine:`, `checkStatus:` (OK/NO/BAD), `isTaggedLine:` |
| `ImapClientTest` | 20 | `nextTag`, `sendCommand:` helpers (untagged/continuation/list), `numberOfMessagesIn:` and `messageCountFromStatusLine:` (incl. empty mailbox) |
| `ImapClientProtocolTest` | 16 | `sendCommand:` against the mock (tag, literals, untagged replies, NO/BAD errors) |
| `ImapClientFetchTest` | 15 | `fetch:using:` paths (header/text/BODY[]), literal reading, reply-line stacking, `fetchMessageStructure:` |
| `ImapClientMailboxesTest` | 3 | `selectMailbox:` (OK/NO), `mailbox` state |
| `ImapClientMessageManagementTest` | 11 | `fetchCapabilities`, `capabilityTokensFromLine:`, `supportsMove`, `deleteMessage:`, `expunge`, `moveMessage:toMailbox:` (MOVE and fallback) |
| `ImapClientMailboxManagementTest` | 7 | `createMailbox:` (incl. quoting of names with spaces), `renameMailbox:toMailbox:` (incl. moving into a parent folder), `deleteMailbox:`, command sequence on one client, `NO` rejection |
| `ImapMessageTest` | 9 | `ImapMessage`/`ImapAttachment`: plain text, RFC-2047 subject, base64/QP body, multipart with attachments, multiple attachments, boundary with trailing parameters |
| `ImapMockStream` (fixture) | – | Serves IMAP literals (`{n}`) repeatedly, back to back |

All tests are offline (using `ImapMockStream`), no network access required.

## Limitations

- Only the **LOGIN** mechanism (no SASL/OAuth, no `AUTHENTICATE PLAIN`).
- **No** ad-hoc commands such as `IDLE`, `SEARCH`, `FETCH` flags or UID-based
  access — but the base (`sendCommand:`) is extensible and passes through any IMAP command.
- `fetchMessage:`, `fetchMessageHeader:` and `fetchMessagesFrom:to:` return **raw data**.
  For structured access use `fetchMessageStructure:` (base64/quoted-printable and
  RFC-2047 are decoded; HTML parts are not extracted, nested `multipart/mixed`
  inner parts are handled recursively).
- Sequence numbers instead of UIDs; numbers can shift when the mailbox changes.
- Mailbox management (`createMailbox:`/`renameMailbox:toMailbox:`/`deleteMailbox:`)
  covers the RFC 3501 commands; creating/renaming/deleting with the UTF-7/UTF-8
  encoded names is passed through unchanged, and a `NO`/`BAD` from the server
  (e.g. deleting a non-empty folder) is raised as an error with the server text.
- All operations are synchronous (one thread, blocking with timeout).
