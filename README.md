# Cuis-Smalltalk Mail

An Internet-ready mail package for Cuis 7.8 — SMTP send (RFC 5321) and IMAP receive (RFC 3501) over TLS, fully headless, no GUI required.

## Contents

| Package | Class | Description |
|---------|-------|-------------|
| `Mail-MailAttachment` | `MailAttachment` | Base class for mail attachments (content type, content, filename); shared by `SmtpAttachment` and `ImapAttachment` |
| `Mail-SmtpClient` | `SmtpClient` | SMTP client: connect, authenticate (AUTH LOGIN), send messages with attachments over SMTPS (port 465) or STARTTLS (port 587) |
| `Mail-SmtpClient` | `SmtpMessage` | RFC 5322 message model: plain text and multipart/mixed with Base64 attachments |
| `Mail-SmtpClient` | `SmtpAttachment` | Attachment helper (inherits from `MailAttachment`) |
| `Mail-ImapClient` | `ImapClient` | IMAP4rev1 client: connect, login, list/select mailboxes, fetch, delete, move, expunge, CREATE/RENAME/DELETE mailboxes |
| `Mail-ImapClient` | `ImapMessage` | Parsed message structure (subject, from, to, date, body, attachments) |
| `Mail-ImapClient` | `ImapAttachment` | Attachment helper (inherits from `MailAttachment`) |
| `Tests-SmtpClient` | — | 39 offline tests (SmtpMockStream) |
| `Tests-ImapClient` | — | 110 offline tests (ImapMockStream) |
| `Tests-MailAttachment` | — | Tests for the base attachment class |

## Requirements

Cuis 7.8, `Network-Kernel`, `WebClient` (both loaded automatically via `!requires:`).

## Quick start

```smalltalk
Feature require: 'Mail-SmtpClient'.
Feature require: 'Mail-ImapClient'.
```

### Send a message

```smalltalk
(SmtpClient new)
    timeout: 10;
    connectToHost: 'smtp.example.com' port: 465;
    login: 'user@example.com' password: 'secret';
    sendMailFrom: 'user@example.com'
        to: #('recipient@example.com')
        subject: 'Hello'
        text: 'This is a test.';
    quit.
```

### Receive a message

```smalltalk
| c msg |
c := ImapClient new.
c timeout: 10.
c secureConnectToHost: 'imap.example.com' port: 993.
c login: 'user@example.com' password: 'secret'.
c selectMailbox: 'INBOX'.
msg := c fetchMessageStructure: 1.
{msg subject. msg body size. msg attachments size}.
c logout.
```

## Documentation

- [docs/IMAPCLIENT.md](docs/IMAPCLIENT.md) / [docs/IMAPCLIENT.en.md](docs/IMAPCLIENT.en.md) — full ImapClient reference
- [docs/SMTPCLIENT.md](docs/SMTPCLIENT.md) / [docs/SMTPCLIENT.en.md](docs/SMTPCLIENT.en.md) — full SmtpClient reference

## License

MIT License. See [LICENSE](LICENSE) for details.
