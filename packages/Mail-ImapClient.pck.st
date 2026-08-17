'From Cuis7.8 [latest update: #7977] on 12 August 2026 at 11:48:00 pm'!
'Description '!
!provides: 'Mail-ImapClient' 1 8!
!requires: 'Mail-MailAttachment' 1 nil 1!
SystemOrganization addCategory: #'Mail-ImapClient'!


!classDefinition: #ImapClient category: #'Mail-ImapClient'!
Object subclass: #ImapClient
	instanceVariableNames: 'stream tagCounter timeout state mailbox capabilities'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mail-ImapClient'!
!classDefinition: 'ImapClient class' category: #'Mail-ImapClient'!
ImapClient class
	instanceVariableNames: ''!

!classDefinition: #ImapMessage category: #'Mail-ImapClient'!
Object subclass: #ImapMessage
	instanceVariableNames: 'subject body attachments header from to date'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mail-ImapClient'!
!classDefinition: 'ImapMessage class' category: #'Mail-ImapClient'!
ImapMessage class
	instanceVariableNames: ''!

!classDefinition: #ImapAttachment category: #'Mail-ImapClient'!
MailAttachment subclass: #ImapAttachment
	instanceVariableNames: 'disposition'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mail-ImapClient'!
!classDefinition: 'ImapAttachment class' category: #'Mail-ImapClient'!
ImapAttachment class
	instanceVariableNames: ''!


!ImapClient methodsFor: 'accessing' stamp: 'rc 8/Aug/2026 23:11:17'!
capabilities
	"Answer the OrderedCollection of capabilities advertised by the server,
	as reported by the CAPABILITY command during connect."
	^ capabilities! !

!ImapClient methodsFor: 'accessing' stamp: 'rc 1/Aug/2026 00:26:45'!
mailbox
	"Answer the currently selected mailbox, or nil."
	^ mailbox
! !

!ImapClient methodsFor: 'accessing' stamp: 'rc 1/Aug/2026 00:26:45'!
state
	"Answer the connection state (#disconnected, #connected or #authenticated)."
	^ state
! !

!ImapClient methodsFor: 'accessing' stamp: 'rc 1/Aug/2026 00:26:45'!
stream
	"Answer the underlying SocketStream, for inspection and debugging."
	^ stream
! !

!ImapClient methodsFor: 'accessing' stamp: 'rc 1/Aug/2026 00:26:45'!
timeout
	"Answer the network timeout in seconds."
	^ timeout
! !

!ImapClient methodsFor: 'accessing' stamp: 'rc 1/Aug/2026 00:26:45'!
timeout: anInteger
	"Set the network timeout in seconds. Takes effect on the next connection."
	timeout := anInteger.
	^ timeout
! !

!ImapClient methodsFor: 'connecting' stamp: 'rc 1/Aug/2026 00:26:45'!
close
	"Close the network connection."
	stream ifNotNil: [stream close].
	stream := nil.
	state := #disconnected.
	mailbox := nil
! !

!ImapClient methodsFor: 'connecting' stamp: 'rc 1/Aug/2026 00:26:45'!
connectToHost: aHostString
	"Connect to an IMAP server on the default port (143)."
	self connectToHost: aHostString port: 143
! !

!ImapClient methodsFor: 'connecting' stamp: 'rc 1/Aug/2026 12:20:01'!
connectToHost: aHostString port: aPortNumber
	"Connect to an IMAP server on the given host and port."
	^ self establishConnectionWith: [ self openStreamToHost: aHostString port: aPortNumber ]! !

!ImapClient methodsFor: 'connecting' stamp: 'rc 8/Aug/2026 23:11:36'!
establishConnectionWith: aStreamOpeningBlock
	"Open a stream via aStreamOpeningBlock, read the server greeting, mark us
	connected, and query the server capabilities."
	stream := aStreamOpeningBlock value.
	self readGreeting.
	state := #connected.
	self fetchCapabilities! !

!ImapClient methodsFor: 'connecting' stamp: 'rc 1/Aug/2026 00:26:45'!
logout
	"Send LOGOUT and close the connection."
	self isConnected ifTrue: [self sendCommand: 'LOGOUT'].
	self close
! !

!ImapClient methodsFor: 'connecting' stamp: 'rc 1/Aug/2026 00:26:45'!
readGreeting
	"Answer the server greeting line.
	Standard servers send it immediately after connecting; some servers
	only send it after the client's first command. A NOOP covers both cases."
	| tag greeting |
	tag := self nextTag.
	self send: tag, ' NOOP'.
	greeting := nil.
	[true] whileTrue: [
		| line |
		line := self readLine.
		line ifNil: [self error: 'Connection closed while waiting for the greeting'].
		(self isTaggedLine: line forTag: tag)
			ifTrue: [^ greeting ifNil: [self error: 'No greeting received from server']].
		(self isUntaggedLine: line) ifTrue: [greeting := line]].
! !

!ImapClient methodsFor: 'connecting' stamp: 'rc 1/Aug/2026 12:20:01'!
secureConnectToHost: aHostString port: aPortNumber
	"Open a TLS (IMAPS) connection to an IMAP server and read its greeting."
	^ self establishConnectionWith: [ self openSecureStreamToHost: aHostString port: aPortNumber ]! !

!ImapClient methodsFor: 'authentication' stamp: 'rc 1/Aug/2026 00:26:45'!
login: aUserName password: aPassword
	"Authenticate using the LOGIN command."
	self sendCommand: 'LOGIN ', (self quoteArg: aUserName), ' ', (self quoteArg: aPassword).
	state := #authenticated.
	^ true
! !

!ImapClient methodsFor: 'mailboxes' stamp: 'rc 1/Aug/2026 00:26:45'!
listMailboxes
	"Answer an OrderedCollection of all mailbox (folder) names."
	| responseLines mailboxNames |
	mailboxNames := OrderedCollection new.
	responseLines := self sendCommand: 'LIST "" "*"'.
	responseLines do: [:responseLine |
		(self isListLine: responseLine) ifTrue: [
			| mailboxName |
			mailboxName := self mailboxNameFromListLine: responseLine.
			mailboxName ifNotNil: [mailboxNames add: mailboxName]]].
	^ mailboxNames
! !

!ImapClient methodsFor: 'mailboxes' stamp: 'rc 5/Aug/2026 17:14:18'!
numberOfMessagesIn: aMailboxName
	"Answer the number of messages in the given mailbox. An empty mailbox answers 0."
	| responseLines |
	responseLines := self sendCommand: 'STATUS ', (self quoteArg: aMailboxName), ' (MESSAGES)'.
	responseLines do: [:responseLine |
		| messageCount |
		messageCount := self messageCountFromStatusLine: responseLine.
		messageCount ifNotNil: [^ messageCount]].
	^ 0! !

!ImapClient methodsFor: 'mailboxes' stamp: 'rc 1/Aug/2026 12:20:10'!
selectMailbox: aMailboxName
	"Select a mailbox; subsequent FETCH calls address messages in it."
	self sendCommand: 'SELECT ', (self quoteArg: aMailboxName).
	mailbox := aMailboxName.
	^ mailbox! !

!ImapClient methodsFor: 'message fetching' stamp: 'rc 1/Aug/2026 12:20:05'!
fetch: aSequenceNumber using: aSection
	"Fetch the given message section; answer its literal content as a String."
	| tag resultStream |
	tag := self nextTag.
	self send: tag, ' FETCH ', aSequenceNumber asString, ' ', aSection.
	resultStream := WriteStream on: String new.
	[self readFetchLine: (self readLine) forTag: tag into: resultStream] whileTrue.
	^ resultStream contents! !

!ImapClient methodsFor: 'message fetching' stamp: 'rc 1/Aug/2026 12:20:05'!
fetchMessage: aSequenceNumber
	"Fetch the full RFC822 message (headers and body) for the given sequence number."
	^ self fetch: aSequenceNumber using: 'BODY[]'! !

!ImapClient methodsFor: 'message fetching' stamp: 'rc 1/Aug/2026 12:20:05'!
fetchMessageHeader: aSequenceNumber
	"Fetch only the RFC822 headers for the given sequence number."
	^ self fetch: aSequenceNumber using: 'BODY[HEADER]'! !

!ImapClient methodsFor: 'message fetching' stamp: 'rc 5/Aug/2026 18:22:31'!
fetchMessageStructure: aSequenceNumber
	"Fetch the full message and answer it as a parsed ImapMessage."
	^ ImapMessage fromRfc822: (self fetchMessage: aSequenceNumber)! !

!ImapClient methodsFor: 'message fetching' stamp: 'rc 1/Aug/2026 12:20:06'!
fetchMessagesFrom: firstSequenceNumber to: lastSequenceNumber
	"Fetch a range of messages by sequence number. Answer an OrderedCollection of message sources."
	| messages |
	messages := OrderedCollection new.
	firstSequenceNumber to: lastSequenceNumber do: [:sequenceNumber |
		messages add: (self fetchMessage: sequenceNumber)].
	^ messages! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 8/Aug/2026 23:11:25'!
capabilityTokensFromLine: aLine
	"Answer an OrderedCollection of capability tokens from a '* CAPABILITY ...' line,
	or an empty collection when aLine is not a capability response."
	| tokens |
	tokens := self tokensIn: aLine.
	^ (tokens size > 2
		and: [(tokens at: 1) = '*'
		and: [(tokens at: 2) asUppercase = 'CAPABILITY']])
		ifTrue: [(tokens allButFirst: 2) asOrderedCollection]
		ifFalse: [OrderedCollection new]! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
checkStatus: aTaggedLine
	"Check the status word of a tagged response; raise an error for NO or BAD."
	| words statusWord |
	words := aTaggedLine findTokens: ' '.
	words size < 2 ifTrue: [self error: 'Malformed IMAP response: ', aTaggedLine].
	statusWord := (words at: 2) asUppercase.
	statusWord = 'OK' ifTrue: [^ self].
	statusWord = 'NO' ifTrue: [self error: 'IMAP NO: ', aTaggedLine].
	statusWord = 'BAD' ifTrue: [self error: 'IMAP BAD: ', aTaggedLine].
	self error: 'Unexpected IMAP tagged response: ', aTaggedLine
! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
isContinuationRequest: aLine
	"Answer whether aLine is a continuation request (starts with '+')."
	^ aLine notEmpty and: [aLine first = $+]
! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
isListLine: aLine
	"Answer whether aLine is a LIST response line."
	^ aLine beginsWith: '* LIST'
! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
isTaggedLine: aLine forTag: aTag
	"Answer whether aLine is the tagged response for aTag."
	^ aLine beginsWith: aTag
! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
isUntaggedLine: aLine
	"Answer whether aLine is an untagged response (starts with '*')."
	^ aLine notEmpty and: [aLine first = $*]
! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
literalSizeFromLine: aLine
	"Answer the literal byte count when aLine ends with {n}, otherwise nil."
	| literalStart |
	(aLine endsWith: '}') ifFalse: [^ nil].
	literalStart := aLine lastIndexOf: ${.
	literalStart = 0 ifTrue: [^ nil].
	^ (aLine copyFrom: literalStart + 1 to: aLine size - 1) asNumber
! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
mailboxNameFromListLine: aLine
	"Extract the mailbox name from a LIST response line."
	| tokens |
	tokens := self tokensIn: aLine.
	tokens isEmpty ifTrue: [^ nil].
	^ self unquote: tokens last
! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 5/Aug/2026 17:14:17'!
messageCountFromStatusLine: aLine
	"Extract the number of messages from a STATUS response line like
	'* STATUS INBOX (MESSAGES 3)'. Answer nil when aLine is not a STATUS line."
	| tokens |
	tokens := self tokensIn: aLine.
	tokens size < 2 ifTrue: [^ nil].
	((tokens first = '*') and: [(tokens second asUppercase) = 'STATUS']) ifFalse: [^ nil].
	2 to: tokens size - 1 do: [:index |
		((tokens at: index) asUppercase endsWith: 'MESSAGES') ifTrue: [
			^ (tokens at: index + 1) asNumber]].
	^ nil! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
quoteArg: aString
	"Answer aString as an IMAP quoted string, escaping backslashes and double quotes."
	^ '"', ((aString copyReplaceAll: '\' with: '\\') copyReplaceAll: '"' with: '\"'), '"'
! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 8/Aug/2026 23:11:29'!
sequenceNumberFromExpungeLine: aLine
	"Answer the sequence number from a '* n EXPUNGE' line, else nil."
	| tokens |
	tokens := self tokensIn: aLine.
	^ (tokens size = 3
		and: [(tokens at: 1) = '*'
		and: [(tokens at: 3) asUppercase = 'EXPUNGE']])
		ifTrue: [(tokens at: 2) asNumber]
		ifFalse: [nil]! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:42:55'!
tokensIn: aString
	"Tokenize aString into an OrderedCollection, honoring double-quoted substrings."
	| tokens inQuote tokenStart |
	tokens := OrderedCollection new.
	inQuote := false.
	tokenStart := 1.
	1 to: aString size do: [:index |
		| character |
		character := aString at: index.
		character = $" ifTrue: [
			inQuote
				ifTrue: [
					inQuote := false.
					tokens add: (aString copyFrom: tokenStart to: index).
					tokenStart := index + 1]
				ifFalse: [inQuote := true. tokenStart := index]].
		(character isSeparator and: [inQuote not])
			ifTrue: [
				(index > tokenStart) ifTrue: [tokens add: (aString copyFrom: tokenStart to: index - 1)].
				tokenStart := index + 1]].
	(tokenStart <= aString size) ifTrue: [tokens add: (aString copyFrom: tokenStart to: aString size)].
	^ tokens! !

!ImapClient methodsFor: 'parsing' stamp: 'rc 1/Aug/2026 00:26:45'!
unquote: aString
	"Remove surrounding double quotes, if present."
	(aString size >= 2 and: [aString first = $" and: [aString last = $"]])
		ifTrue: [^ aString copyFrom: 2 to: aString size - 1].
	^ aString
! !

!ImapClient methodsFor: 'testing' stamp: 'rc 1/Aug/2026 00:26:45'!
isConnected
	"Answer whether the connection is open."
	^ state = #connected or: [state = #authenticated]
! !

!ImapClient methodsFor: 'testing' stamp: 'rc 8/Aug/2026 23:11:21'!
supportsMove
	"Answer whether the server supports the MOVE command (RFC 6851)."
	^ capabilities anySatisfy: [:aCapability | aCapability asUppercase = 'MOVE']! !

!ImapClient methodsFor: 'initialization' stamp: 'rc 8/Aug/2026 23:11:14'!
initialize
	super initialize.
	tagCounter := 0.
	timeout := 60.
	state := #disconnected.
	mailbox := nil.
	capabilities := OrderedCollection new! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 00:26:45'!
configureStream: aSocketStream
	"Set line-delimited text mode and the network timeout."
	aSocketStream ascii.
	aSocketStream timeout: timeout.
	^ aSocketStream
! !

!ImapClient methodsFor: 'private' stamp: 'rc 8/Aug/2026 23:11:33'!
fetchCapabilities
	"Ask the server for its capabilities and store them; answer the capabilities."
	capabilities := OrderedCollection new.
	(self sendCommand: 'CAPABILITY') do: [:responseLine |
		(self capabilityTokensFromLine: responseLine) do: [:aCapability |
			capabilities add: aCapability]].
	^ capabilities! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 12:20:11'!
nextTag
	"Answer the next command tag, an ever-increasing 'a1', 'a2', ... used to match tagged responses."
	tagCounter := tagCounter + 1.
	^ 'a', tagCounter printString! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 12:20:11'!
openSecureStreamToHost: aHostString port: aPortNumber
	"Open a TLS socket stream to the given host and port and perform the TLS handshake."
	| secureStream |
	secureStream := self configureStream: (SecureSocketStream openConnectionToHostNamed: aHostString port: aPortNumber).
	secureStream sslConnectTo: aHostString.
	^ secureStream! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 12:20:10'!
openStreamToHost: aHostString port: aPortNumber
	"Open a plain TCP socket stream to the given host and port."
	^ self configureStream: (SocketStream openConnectionToHostNamed: aHostString port: aPortNumber)! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 00:26:45'!
readFetchLine: aLine forTag: aTag into: aWriteStream
	"Classify one FETCH response line. Answer true while the tagged response has not arrived.
	The literal content of untagged lines is appended to aWriteStream."
	| literalSize |
	aLine ifNil: [self error: 'Connection closed while waiting for a FETCH response'].
	(self isTaggedLine: aLine forTag: aTag)
		ifTrue: [self checkStatus: aLine. ^ false].
	(self isUntaggedLine: aLine) ifTrue: [
		literalSize := self literalSizeFromLine: aLine.
		literalSize ifNotNil: [aWriteStream nextPutAll: (stream next: literalSize)]].
	^ true
! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 00:26:45'!
readLine
	"Read one CRLF-terminated line from the server."
	^ stream nextLineCrLf
! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 00:26:45'!
readLiteralIfPresentIn: aLine
	"Answer aLine, followed by the literal content when aLine declares one ({n})."
	| literalSize |
	literalSize := self literalSizeFromLine: aLine.
	literalSize ifNil: [^ aLine].
	^ aLine, Character cr asString, (stream next: literalSize)
! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 00:26:45'!
readResponseLine: aLine forTag: aTag into: aCollection
	"Classify one server line. Answer true while the tagged response has not arrived.
	Untagged lines are collected (with literal content); continuation requests and
	empty lines are ignored; anything else raises an error."
	aLine ifNil: [self error: 'Connection closed while waiting for an IMAP response'].
	aLine isEmpty ifTrue: [^ true].
	(self isTaggedLine: aLine forTag: aTag)
		ifTrue: [self checkStatus: aLine. ^ false].
	(self isUntaggedLine: aLine)
		ifTrue: [aCollection add: (self readLiteralIfPresentIn: aLine)]
		ifFalse: [(self isContinuationRequest: aLine) ifFalse: [self error: 'Unexpected IMAP response: ', aLine]].
	^ true
! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 00:26:45'!
send: aString
	"Write aString plus CRLF to the server."
	stream nextPutAll: aString; crlf; flush
! !

!ImapClient methodsFor: 'private' stamp: 'rc 1/Aug/2026 00:26:45'!
sendCommand: aString
	"Send a tagged command and wait for the matching tagged response.
	Answer an OrderedCollection of untagged response lines.
	Raise an error when the server answers NO or BAD."
	| tag responseLines |
	tag := self nextTag.
	self send: tag, ' ', aString.
	responseLines := OrderedCollection new.
	[self readResponseLine: (self readLine) forTag: tag into: responseLines] whileTrue.
	^ responseLines
! !

!ImapClient methodsFor: 'message management' stamp: 'rc 8/Aug/2026 23:11:40'!
deleteMessage: aSequenceNumber
	"Mark the given message in the selected mailbox as deleted by setting the
	\Deleted flag. The message is removed permanently only by #expunge."
	self sendCommand: 'STORE ', aSequenceNumber printString, ' +FLAGS.SILENT (\Deleted)'! !

!ImapClient methodsFor: 'message management' stamp: 'rc 8/Aug/2026 23:11:44'!
expunge
	"Remove all messages marked \Deleted from the selected mailbox.
	Answer an OrderedCollection of the sequence numbers of the removed messages."
	| responseLines expunged |
	expunged := OrderedCollection new.
	responseLines := self sendCommand: 'EXPUNGE'.
	responseLines do: [:responseLine |
		(self sequenceNumberFromExpungeLine: responseLine) ifNotNil: [:sequenceNumber |
			expunged add: sequenceNumber]].
	^ expunged! !

!ImapClient methodsFor: 'message management' stamp: 'rc 8/Aug/2026 23:11:48'!
moveMessage: aSequenceNumber toMailbox: aMailboxName
	"Move the given message in the selected mailbox to another mailbox.
	Uses MOVE (RFC 6851) when the server supports it; otherwise COPY,
	then \Deleted, then EXPUNGE."
	self supportsMove
		ifTrue: [self sendCommand: 'MOVE ', aSequenceNumber printString, ' ', (self quoteArg: aMailboxName)]
		ifFalse: [
			self sendCommand: 'COPY ', aSequenceNumber printString, ' ', (self quoteArg: aMailboxName).
			self deleteMessage: aSequenceNumber.
			self expunge]! !

!ImapClient methodsFor: 'mailbox management' stamp: 'rc 9/Aug/2026 17:45:23'!
createMailbox: aMailboxName
	"Create a new mailbox with the given name (CREATE, RFC 3501).
	Answer the created mailbox name."
	self sendCommand: 'CREATE ', (self quoteArg: aMailboxName).
	^ aMailboxName! !

!ImapClient methodsFor: 'mailbox management' stamp: 'rc 9/Aug/2026 17:45:30'!
deleteMailbox: aMailboxName
	"Delete the given mailbox (DELETE, RFC 3501).
	Answer the deleted mailbox name."
	self sendCommand: 'DELETE ', (self quoteArg: aMailboxName).
	^ aMailboxName! !

!ImapClient methodsFor: 'mailbox management' stamp: 'rc 9/Aug/2026 17:45:27'!
renameMailbox: aMailboxName toMailbox: aNewMailboxName
	"Rename the given mailbox to a new name (RENAME, RFC 3501).
	Moving a mailbox into another folder is done by giving a full target
	name that includes the target parent. Answer the new mailbox name."
	self sendCommand: 'RENAME ', (self quoteArg: aMailboxName), ' ', (self quoteArg: aNewMailboxName).
	^ aNewMailboxName! !

!ImapMessage methodsFor: 'accessing' stamp: 'rc 5/Aug/2026 18:13:21'!
attachments
	^ attachments! !

!ImapMessage methodsFor: 'accessing' stamp: 'rc 5/Aug/2026 18:13:19'!
body
	^ body! !

!ImapMessage methodsFor: 'accessing' stamp: 'rc 5/Aug/2026 18:13:30'!
date
	^ date! !

!ImapMessage methodsFor: 'accessing' stamp: 'rc 5/Aug/2026 18:13:26'!
from
	^ from! !

!ImapMessage methodsFor: 'accessing' stamp: 'rc 5/Aug/2026 18:13:24'!
header
	^ header! !

!ImapMessage methodsFor: 'accessing' stamp: 'rc 5/Aug/2026 18:13:17'!
subject
	^ subject! !

!ImapMessage methodsFor: 'accessing' stamp: 'rc 5/Aug/2026 18:13:28'!
to
	^ to! !

!ImapMessage methodsFor: 'parsing' stamp: 'rc 5/Aug/2026 18:21:09'!
contentOfPart: aPart
	"Parse a single MIME part. Answer its decoded text content, or nil if the part
	was an attachment (which is added to the attachments collection instead)."
	| headerAndBody headerString bodyString fields partType partDisposition partEncoding |
	headerAndBody := self splitHeaderAndBody: aPart.
	headerString := headerAndBody first.
	bodyString := headerAndBody second.
	fields := self headerFieldsFrom: headerString.
	partType := (fields at: 'content-type' ifAbsent: ['text/plain']).
	partDisposition := fields at: 'content-disposition' ifAbsent: [nil].
	partEncoding := fields at: 'content-transfer-encoding' ifAbsent: [nil].
	(partType asLowercase beginsWith: 'multipart/')
		ifTrue: [^ self parseMultipartBody: bodyString contentType: partType].
	(self isAttachmentType: partType disposition: partDisposition)
		ifTrue: [
			attachments add: (ImapAttachment
				fileName: (self fileNameFrom: fields)
				contentType: partType
				content: (self decodeContentBytes: bodyString transferEncoding: partEncoding)
				disposition: partDisposition).
			^ nil].
	^ self decodeContentText: bodyString contentType: partType transferEncoding: partEncoding! !

!ImapMessage methodsFor: 'parsing' stamp: 'rc 5/Aug/2026 18:21:01'!
parseBody: aString
	| contentType disposition transferEncoding |
	contentType := (header at: 'content-type' ifAbsent: ['text/plain']).
	disposition := header at: 'content-disposition' ifAbsent: [nil].
	transferEncoding := header at: 'content-transfer-encoding' ifAbsent: [nil].
	(contentType asLowercase beginsWith: 'multipart/')
		ifTrue: [body := (self parseMultipartBody: aString contentType: contentType) withBlanksTrimmed]
		ifFalse: [
			(self isAttachmentType: contentType disposition: disposition)
				ifTrue: [
					body := ''.
					attachments add: (ImapAttachment
						fileName: (self fileNameFrom: header)
						contentType: contentType
						content: (self decodeContentBytes: aString transferEncoding: transferEncoding)
						disposition: disposition)]
				ifFalse: [
					body := self decodeContentText: aString contentType: contentType transferEncoding: transferEncoding]]! !

!ImapMessage methodsFor: 'parsing' stamp: 'rc 5/Aug/2026 18:20:57'!
parseHeader: aString
	| fields |
	fields := self headerFieldsFrom: aString.
	header := fields.
	subject := self decodeEncodedWordsIn: (fields at: 'subject' ifAbsent: [nil]).
	from := self decodeEncodedWordsIn: (fields at: 'from' ifAbsent: [nil]).
	to := self decodeEncodedWordsIn: (fields at: 'to' ifAbsent: [nil]).
	date := fields at: 'date' ifAbsent: [nil]! !

!ImapMessage methodsFor: 'parsing' stamp: 'rc 5/Aug/2026 18:21:04'!
parseMultipartBody: aString contentType: contentType
	"Parse a multipart body. Answer the concatenated text of its text parts and
	collect any attachment parts. Handles nested multipart parts recursively."
	| boundary parts bodyStream |
	boundary := self boundaryFrom: contentType.
	boundary ifNil: [^ aString].
	parts := self partsFromMultipartBody: aString boundary: boundary.
	bodyStream := WriteStream on: String new.
	parts do: [:part |
		(self contentOfPart: part) ifNotNil: [:text | bodyStream nextPutAll: text; newLine]].
	^ bodyStream contents! !

!ImapMessage methodsFor: 'parsing' stamp: 'rc 5/Aug/2026 18:20:45'!
parseRfc822: aString
	| headerAndBody headerString bodyString |
	attachments := OrderedCollection new.
	headerAndBody := self splitHeaderAndBody: aString.
	headerString := headerAndBody first.
	bodyString := headerAndBody second.
	self parseHeader: headerString.
	self parseBody: bodyString.
	^ self! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:21:51'!
base64Decode: aString
	"Decode a base64 String (ignoring whitespace and line breaks) into a ByteArray."
	^ Base64MimeConverter mimeDecode: (aString select: [:c | c isSeparator not])! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:41:22'!
boundaryFrom: aContentType
	"Extract the MIME boundary parameter from a Content-Type header value, or nil."
	^ self parameterValue: 'boundary' from: aContentType! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:22:09'!
bytesFromString: aString
	"Answer aString's characters as a ByteArray of their byte values."
	| bytes |
	bytes := ByteArray new: aString size.
	1 to: aString size do: [:i | bytes at: i put: (aString at: i) asciiValue].
	^ bytes! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:41:26'!
charsetFrom: aContentType
	"Extract the charset parameter from a Content-Type header value, or nil."
	^ self parameterValue: 'charset' from: aContentType! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:21:48'!
decodeContentBytes: aString transferEncoding: anEncoding
	"Decode an attachment part's content, answering raw bytes for base64 and the
	original String otherwise."
	| lowerEncoding |
	lowerEncoding := (anEncoding ifNil: ['7bit']) asLowercase withBlanksTrimmed.
	lowerEncoding = 'base64' ifTrue: [^ self base64Decode: aString].
	^ aString! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:21:44'!
decodeContentText: aString contentType: aType transferEncoding: anEncoding
	"Decode a text part's content, answering a String. Handles base64 and
	quoted-printable transfer encodings."
	| lowerEncoding charset |
	lowerEncoding := (anEncoding ifNil: ['7bit']) asLowercase withBlanksTrimmed.
	charset := self charsetFrom: aType.
	lowerEncoding = 'base64'
		ifTrue: [^ self stringFromBytes: (self base64Decode: aString) charset: charset].
	lowerEncoding = 'quoted-printable'
		ifTrue: [^ self stringFromBytes: (self quotedPrintableDecode: aString) charset: charset].
	charset ifNotNil: [
		(charset asLowercase includesSubString: 'utf')
			ifTrue: [^ UnicodeString fromUtf8Bytes: (self bytesFromString: aString)]].
	^ aString! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:22:21'!
decodeEncodedWord: aString
	"Decode a single RFC 2047 encoded word. Answer aString unchanged when it is
	not a valid encoded word."
	| parts encoding data |
	(aString beginsWith: '=?') ifFalse: [^ aString].
	parts := (aString copyFrom: 3 to: aString size - 2) findTokens: $?.
	parts size = 3 ifFalse: [^ aString].
	encoding := (parts at: 2) asUppercase.
	data := parts at: 3.
	encoding = 'B'
		ifTrue: [^ self stringFromBytes: (self base64Decode: data) charset: (parts at: 1)].
	encoding = 'Q'
		ifTrue: [^ self stringFromBytes: (self quotedPrintableDecode: (data copyReplaceAll: '_' with: ' ')) charset: (parts at: 1)].
	^ aString! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:22:15'!
decodeEncodedWordsIn: aString
	"Decode RFC 2047 encoded words (=?charset?B?...?= / =?charset?Q?...?=) in aString."
	| out searchStart encodedStart encodedEnd rest |
	aString ifNil: [^ nil].
	(aString includesSubString: '=?') ifFalse: [^ aString].
	out := WriteStream on: String new.
	rest := aString.
	[(encodedStart := rest findString: '=?' startingAt: 1) > 0] whileTrue: [
		out nextPutAll: (rest copyFrom: 1 to: encodedStart - 1).
		encodedEnd := rest findString: '?=' startingAt: encodedStart + 2.
		encodedEnd = 0
			ifTrue: [
				out nextPutAll: (rest copyFrom: encodedStart to: rest size).
				rest := '']
			ifFalse: [
				out nextPutAll: (self decodeEncodedWord: (rest copyFrom: encodedStart to: encodedEnd + 1)).
				rest := rest copyFrom: encodedEnd + 2 to: rest size]].
	out nextPutAll: rest.
	^ out contents! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:41:31'!
fileNameFrom: fields
	"Extract a file name from a header fields Dictionary (filename= or name=), or a default."
	| disposition type name |
	disposition := fields at: 'content-disposition' ifAbsent: [nil].
	name := self parameterValue: 'filename' from: disposition.
	name ifNil: [
		type := fields at: 'content-type' ifAbsent: [nil].
		name := self parameterValue: 'name' from: type].
	name ifNil: [name := 'attachment'].
	^ name! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:20:54'!
headerFieldsFrom: aString
	"Parse a header section into a Dictionary, folding continuation lines and
	lowercasing field names."
	| fields currentName currentValue colonIndex |
	fields := Dictionary new.
	currentName := nil.
	currentValue := ''.
	aString linesDo: [:line |
		(line size > 0 and: [line first isSeparator])
			ifTrue: [currentValue := currentValue, ' ', line withBlanksTrimmed]
			ifFalse: [
				currentName ifNotNil: [fields at: currentName put: currentValue].
				colonIndex := line indexOf: $: startingAt: 1.
				colonIndex > 0
					ifTrue: [
						currentName := (line copyFrom: 1 to: colonIndex - 1) asLowercase withBlanksTrimmed.
						currentValue := (line copyFrom: colonIndex + 1 to: line size) withBlanksTrimmed]
					ifFalse: [currentName := nil]]].
	currentName ifNotNil: [fields at: currentName put: currentValue].
	^ fields! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:22:02'!
hexValueOf: aCharacter
	| upper |
	upper := aCharacter asUppercase.
	^ upper isDigit
		ifTrue: [upper digitValue]
		ifFalse: [('ABCDEF' indexOf: upper) + 9]! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:21:31'!
isAttachmentType: aContentType disposition: aDisposition
	"Answer whether a part with the given Content-Type and Content-Disposition is an attachment.
	A non-text part is an attachment; a text part is only an attachment when explicitly
	labelled as such."
	aDisposition notNil ifTrue: [^ aDisposition asLowercase includesSubString: 'attachment'].
	^ (aContentType asLowercase beginsWith: 'text/') not! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:21:59'!
isHexDigit: aCharacter
	^ '0123456789ABCDEF' includes: aCharacter asUppercase! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:21:17'!
lineEndAfter: aStart in: aString
	"Answer the position just after the line terminator of the line starting at aStart, or 0."
	| index |
	index := aString findString: String lfString startingAt: aStart.
	index = 0 ifTrue: [^ 0].
	^ index + 1! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:41:18'!
parameterValue: aName from: aContentType
	"Answer the value of MIME parameter aName (case-insensitive) from a header value.
	Stops at the next semicolon or closing quote. Answer nil when absent."
	| lowerText index position quotePosition semicolonPosition candidate |
	aContentType ifNil: [^ nil].
	lowerText := aContentType asLowercase.
	index := lowerText findString: aName asLowercase, '=' startingAt: 1.
	index = 0 ifTrue: [^ nil].
	position := index + aName size + 1.
	position > aContentType size ifTrue: [^ nil].
	candidate := (aContentType copyFrom: position to: aContentType size) withBlanksTrimmed.
	candidate ifEmpty: [^ nil].
	candidate first = $"
		ifTrue: [
			quotePosition := candidate findString: '"' startingAt: 2.
			quotePosition = 0 ifTrue: [^ nil].
			^ candidate copyFrom: 2 to: quotePosition - 1].
	semicolonPosition := candidate findString: ';' startingAt: 1.
	semicolonPosition > 0
		ifTrue: [^ (candidate copyFrom: 1 to: semicolonPosition - 1) withBlanksTrimmed].
	^ candidate! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:29:51'!
partsFromMultipartBody: aString boundary: aBoundary
	"Split a multipart body into its parts, ignoring preamble and epilogue and
	stripping the framing CRLF that precedes each boundary delimiter."
	| parts delimiter searchStart partStart boundaryIndex afterDelimiter |
	parts := OrderedCollection new.
	delimiter := '--', aBoundary.
	searchStart := aString findString: delimiter startingAt: 1.
	[searchStart > 0] whileTrue: [
		afterDelimiter := searchStart + delimiter size.
		(afterDelimiter + 1 <= aString size
			and: [(aString at: afterDelimiter) = $-
			and: [(aString at: afterDelimiter + 1) = $-]])
			ifTrue: [^ parts].
		partStart := self lineEndAfter: searchStart in: aString.
		partStart = 0 ifTrue: [^ parts].
		boundaryIndex := aString findString: delimiter startingAt: partStart.
		boundaryIndex = 0
			ifTrue: [
				parts add: (self stripTrailingLineBreak: (aString copyFrom: partStart to: aString size)).
				^ parts].
		parts add: (self stripTrailingLineBreak: (aString copyFrom: partStart to: boundaryIndex - 1)).
		searchStart := boundaryIndex].
	^ parts! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:21:56'!
quotedPrintableDecode: aString
	"Decode quoted-printable content into a ByteArray, handling =XX escapes and
	soft line breaks (= at end of line)."
	| cleaned out i c |
	cleaned := aString copyReplaceAll: String crString with: ''.
	out := WriteStream on: ByteArray new.
	i := 1.
	[i <= cleaned size] whileTrue: [
		c := cleaned at: i.
		c = $=
			ifTrue: [
				(i + 1 <= cleaned size and: [(cleaned at: i + 1) = Character lf])
					ifTrue: [i := i + 2]
					ifFalse: [
						(i + 2 <= cleaned size
							and: [(self isHexDigit: (cleaned at: i + 1))
							and: [(self isHexDigit: (cleaned at: i + 2))]])
							ifTrue: [
								out nextPut: (self hexValueOf: (cleaned at: i + 1)) * 16 + (self hexValueOf: (cleaned at: i + 2)).
								i := i + 3]
							ifFalse: [out nextPut: c asciiValue. i := i + 1]]]
			ifFalse: [out nextPut: c asciiValue. i := i + 1]].
	^ out contents! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:20:49'!
splitHeaderAndBody: aString
	"Answer {headerString. bodyString}, splitting on the first blank line."
	| index sepSize |
	index := aString findString: String crlfString, String crlfString startingAt: 1.
	index = 0
		ifTrue: [
			index := aString findString: String lfString, String lfString startingAt: 1.
			index = 0 ifTrue: [^ Array with: aString with: ''].
			sepSize := 2]
		ifFalse: [sepSize := 4].
	^ Array
		with: (aString copyFrom: 1 to: index - 1)
		with: (aString copyFrom: index + sepSize to: aString size)! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:24:02'!
stringFromBytes: aBytes charset: aCharset
	"Answer a String from decoded bytes, interpreting them as UTF-8 when the
	charset is UTF-8 (or unspecified), otherwise as latin-1 bytes."
	^ [(aCharset isNil or: [(aCharset asLowercase includesSubString: 'utf')])
		ifTrue: [UnicodeString fromUtf8Bytes: aBytes]
		ifFalse: [aBytes asString]]
		on: Error
		do: [:ex | aBytes asString]! !

!ImapMessage methodsFor: 'private' stamp: 'rc 5/Aug/2026 18:29:42'!
stripTrailingLineBreak: aString
	"Answer aString without a trailing CRLF, LF or CR, if present."
	(aString endsWith: String crlfString)
		ifTrue: [^ aString copyFrom: 1 to: aString size - 2].
	(aString endsWith: String lfString)
		ifTrue: [^ aString copyFrom: 1 to: aString size - 1].
	(aString endsWith: String crString)
		ifTrue: [^ aString copyFrom: 1 to: aString size - 1].
	^ aString! !

!ImapMessage class methodsFor: 'instance creation' stamp: 'rc 5/Aug/2026 18:20:42'!
fromRfc822: aString
	"Parse an RFC822 message source and answer a new ImapMessage."
	^ self new parseRfc822: aString! !

!ImapAttachment methodsFor: 'initialize-release' stamp: 'rc 5/Aug/2026 18:13:03'!
initializeFileName: aString contentType: aType content: aContent disposition: aDisposition
	fileName := aString.
	contentType := aType.
	content := aContent.
	disposition := aDisposition! !

!ImapAttachment methodsFor: 'accessing' stamp: 'rc 5/Aug/2026 18:13:11'!
disposition
	^ disposition! !

!ImapAttachment class methodsFor: 'instance creation' stamp: 'rc 5/Aug/2026 18:24:30'!
fileName: aString contentType: aType content: aContent disposition: aDisposition
	^ self new initializeFileName: aString contentType: aType content: aContent disposition: aDisposition! !