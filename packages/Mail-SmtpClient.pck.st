'From Cuis7.8 [latest update: #7977] on 12 August 2026 at 11:48:01 pm'!
'Description '!
!provides: 'Mail-SmtpClient' 1 3!
!requires: 'Mail-MailAttachment' 1 nil 1!
SystemOrganization addCategory: #'Mail-SmtpClient'!


!classDefinition: #SmtpAttachment category: #'Mail-SmtpClient'!
MailAttachment subclass: #SmtpAttachment
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mail-SmtpClient'!
!classDefinition: 'SmtpAttachment class' category: #'Mail-SmtpClient'!
SmtpAttachment class
	instanceVariableNames: ''!

!classDefinition: #SmtpClient category: #'Mail-SmtpClient'!
Object subclass: #SmtpClient
	instanceVariableNames: 'state stream timeout hostName capabilities'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mail-SmtpClient'!
!classDefinition: 'SmtpClient class' category: #'Mail-SmtpClient'!
SmtpClient class
	instanceVariableNames: ''!

!classDefinition: #SmtpMessage category: #'Mail-SmtpClient'!
Object subclass: #SmtpMessage
	instanceVariableNames: 'from to cc subject text attachments date'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mail-SmtpClient'!
!classDefinition: 'SmtpMessage class' category: #'Mail-SmtpClient'!
SmtpMessage class
	instanceVariableNames: ''!


!SmtpClient methodsFor: 'initialization' stamp: 'rc 6/Aug/2026 05:19:01'!
initialize
	super initialize.
	timeout := 60.
	state := #disconnected.
	hostName := nil.
	capabilities := OrderedCollection new.! !

!SmtpClient methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:19:03'!
capabilities
	"Answer the capabilities advertised by the server after EHLO."
	^ capabilities! !

!SmtpClient methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:19:01'!
state
	"Answer the current state: #disconnected, #connected or #authenticated."
	^ state! !

!SmtpClient methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:19:02'!
stream
	"Answer the underlying SocketStream (for inspection/debugging)."
	^ stream! !

!SmtpClient methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:19:02'!
timeout
	"Answer the network timeout in seconds."
	^ timeout! !

!SmtpClient methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:19:02'!
timeout: anInteger
	"Set the network timeout in seconds. Takes effect on the next connection."
	timeout := anInteger.
	^ timeout! !

!SmtpClient methodsFor: 'connecting' stamp: 'rc 6/Aug/2026 05:19:09'!
close
	"Close the network connection and reset the client state."
	stream ifNotNil: [stream close].
	stream := nil.
	capabilities := OrderedCollection new.
	state := #disconnected! !

!SmtpClient methodsFor: 'connecting' stamp: 'rc 6/Aug/2026 05:19:06'!
connectToHost: aHostString
	"Connect to an SMTP server on the default port (25)."
	self connectToHost: aHostString port: 25! !

!SmtpClient methodsFor: 'connecting' stamp: 'rc 6/Aug/2026 05:19:07'!
connectToHost: aHostString port: aPortNumber
	"Connect to an SMTP server on the given host and port, read the greeting and send EHLO."
	hostName := aHostString.
	^ self establishConnectionWith: [self openStreamToHost: aHostString port: aPortNumber]! !

!SmtpClient methodsFor: 'connecting' stamp: 'rc 6/Aug/2026 05:57:31'!
establishConnectionWith: aStreamOpeningBlock
	"Open a stream via aStreamOpeningBlock, read the greeting, and negotiate capabilities via EHLO."
	stream := aStreamOpeningBlock value.
	self readGreeting.
	state := #connected! !

!SmtpClient methodsFor: 'connecting' stamp: 'rc 6/Aug/2026 05:19:09'!
quit
	"Send QUIT and close the connection."
	self isConnected ifTrue: [self sendCommand: 'QUIT'].
	self close! !

!SmtpClient methodsFor: 'connecting' stamp: 'rc 6/Aug/2026 05:59:07'!
readGreeting
	"Send EHLO and read the greeting plus the EHLO response. Some servers (notably on
	implicit TLS) only send their 220 greeting after the client has sent something, and
	others skip it entirely once a command arrived. Handle both orders."
	| firstReply greeting replyLines |
	self send: 'EHLO ', self localHostName.
	firstReply := self readReply.
	(firstReply notEmpty and: [firstReply first beginsWith: '220'])
		ifTrue: [
			greeting := firstReply.
			replyLines := self readReply.
			self checkReply: greeting.
			self parseCapabilities: replyLines.
			^ greeting]
		ifFalse: [
			replyLines := firstReply.
			self checkReply: replyLines.
			self parseCapabilities: replyLines.
			^ replyLines]! !

!SmtpClient methodsFor: 'connecting' stamp: 'rc 6/Aug/2026 05:19:08'!
secureConnectToHost: aHostString port: aPortNumber
	"Open a TLS (SMTPS) connection to an SMTP server, read the greeting and send EHLO."
	hostName := aHostString.
	^ self establishConnectionWith: [self openSecureStreamToHost: aHostString port: aPortNumber]! !

!SmtpClient methodsFor: 'connecting' stamp: 'rc 6/Aug/2026 05:19:08'!
startTls
	"Upgrade the current connection to TLS via STARTTLS (RFC 3207) and re-negotiate capabilities."
	| secureStream |
	self checkReply: (self sendCommand: 'STARTTLS').
	secureStream := SecureSocketStream on: stream socket.
	secureStream sslConnectTo: hostName.
	stream := secureStream.
	self configureStream: stream.
	self ehlo! !

!SmtpClient methodsFor: 'authentication' stamp: 'rc 6/Aug/2026 05:19:15'!
login: aUserName password: aPassword
	"Authenticate via AUTH LOGIN and set the state to #authenticated on success."
	self checkReply: (self sendCommand: 'AUTH LOGIN').
	self checkReply: (self sendCommand: (self base64Encode: aUserName)).
	self checkReply: (self sendCommand: (self base64Encode: aPassword)).
	state := #authenticated! !

!SmtpClient methodsFor: 'sending' stamp: 'rc 6/Aug/2026 05:57:29'!
ehlo
	"Send EHLO and store the advertised capabilities."
	self parseCapabilities: (self checkReply: (self sendCommand: 'EHLO ', self localHostName))! !

!SmtpClient methodsFor: 'sending' stamp: 'rc 6/Aug/2026 05:57:26'!
parseCapabilities: replyLines
	"Store the capabilities advertised in an EHLO response."
	capabilities := (replyLines allButFirst collect: [:aLine | aLine copyFrom: 5 to: aLine size]) asOrderedCollection! !

!SmtpClient methodsFor: 'sending' stamp: 'rc 6/Aug/2026 05:19:18'!
sendData: aMailSourceString
	"Send the message body in the DATA phase with dot-stuffing and the terminating dot."
	| stuffed |
	stuffed := self dotStuff: aMailSourceString.
	stream
		nextPutAll: stuffed;
		nextPutAll: '.';
		crlf;
		flush.
	^ self checkReply: self readReply! !

!SmtpClient methodsFor: 'sending' stamp: 'rc 6/Aug/2026 05:19:16'!
sendMailFrom: aFromAddress to: aToAddresses subject: aSubjectString text: aTextString
	"Send a text-only mail."
	^ self sendMessage: (SmtpMessage
		from: aFromAddress
		to: aToAddresses
		subject: aSubjectString
		text: aTextString)! !

!SmtpClient methodsFor: 'sending' stamp: 'rc 6/Aug/2026 05:19:17'!
sendMailFrom: aFromAddress to: aToAddresses subject: aSubjectString text: aTextString attachments: anAttachmentCollection
	"Send a text mail with one or more attachments."
	^ self sendMessage: (SmtpMessage
		from: aFromAddress
		to: aToAddresses
		subject: aSubjectString
		text: aTextString
		attachments: anAttachmentCollection)! !

!SmtpClient methodsFor: 'sending' stamp: 'rc 6/Aug/2026 05:19:16'!
sendMessage: anSmtpMessage
	"Send anSmtpMessage to all its recipients."
	self checkReply: (self sendCommand: 'MAIL FROM:<', anSmtpMessage from, '>').
	anSmtpMessage recipients do: [:recipient |
		self checkReply: (self sendCommand: 'RCPT TO:<', recipient, '>')].
	self checkReply: (self sendCommand: 'DATA').
	^ self sendData: anSmtpMessage rfc822Source! !

!SmtpClient methodsFor: 'parsing' stamp: 'rc 6/Aug/2026 05:19:24'!
checkReply: aReplyLinesCollection
	"Raise an error when the reply code is not positive (2xx/3xx); answer the reply otherwise."
	| code |
	code := self replyCode: aReplyLinesCollection.
	(self isPositiveReplyCode: code)
		ifFalse: [self error: 'SMTP ', code printString, ': ', (self replyText: aReplyLinesCollection)].
	^ aReplyLinesCollection! !

!SmtpClient methodsFor: 'parsing' stamp: 'rc 6/Aug/2026 05:19:23'!
isPositiveReplyCode: anInteger
	"Answer whether anInteger is a positive (2xx/3xx) SMTP reply code."
	^ anInteger >= 200 and: [anInteger < 400]! !

!SmtpClient methodsFor: 'parsing' stamp: 'rc 6/Aug/2026 05:19:22'!
readReply
	"Answer the (multi-line) reply to the last command as an OrderedCollection of lines."
	| reply line |
	reply := OrderedCollection new.
	[true] whileTrue: [
		line := self readLine.
		line ifNil: [self error: 'Connection closed during SMTP reply'].
		reply add: line.
		(line size >= 4 and: [(line at: 4) ~= $-]) ifTrue: [^ reply]]! !

!SmtpClient methodsFor: 'parsing' stamp: 'rc 6/Aug/2026 05:19:23'!
replyCode: aReplyLinesCollection
	"Answer the three-digit reply code of a reply."
	^ (aReplyLinesCollection first copyFrom: 1 to: 3) asNumber! !

!SmtpClient methodsFor: 'parsing' stamp: 'rc 6/Aug/2026 05:19:25'!
supportsAuthentication
	"Answer whether the server advertises SMTP authentication."
	^ capabilities anySatisfy: [:aCapability | aCapability asUppercase beginsWith: 'AUTH']! !

!SmtpClient methodsFor: 'parsing' stamp: 'rc 6/Aug/2026 05:19:25'!
supportsStartTls
	"Answer whether the server advertises STARTTLS."
	^ capabilities anySatisfy: [:aCapability | aCapability asUppercase = 'STARTTLS']! !

!SmtpClient methodsFor: 'testing' stamp: 'rc 6/Aug/2026 05:19:26'!
isConnected
	"Answer whether the connection is open."
	^ state = #connected or: [state = #authenticated]! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:30'!
base64Encode: aContent
	"Answer aContent (a String or a ByteArray) as a single-line base64 string."
	| bytes |
	bytes := aContent isString
		ifTrue: [aContent asUtf8Bytes]
		ifFalse: [aContent].
	^ (Base64MimeConverter mimeEncode: bytes readStream multiLine: false) contents! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:30'!
configureStream: aSocketStream
	"Set line-delimited text mode and the network timeout."
	aSocketStream ascii.
	aSocketStream timeout: timeout.
	^ aSocketStream! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:39:47'!
dotStuff: aString
	"Answer aString with CRLF line endings and SMTP dot-stuffing (a leading '.' is doubled), ending in a single CRLF."
	| source output |
	source := aString withLineEndings: String crlfString.
	(source endsWith: String crlfString) ifTrue: [source := source copyFrom: 1 to: source size - 2].
	output := WriteStream on: (String new: source size).
	source linesDo: [:eachLine |
		(eachLine notEmpty and: [eachLine first = $.]) ifTrue: [output nextPut: $.].
		output
			nextPutAll: eachLine;
			nextPutAll: String crlfString].
	^ output contents! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:32'!
localHostName
	"Answer the local host name used in the EHLO command."
	^ NetNameResolver localHostName! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:34'!
openSecureStreamToHost: aHostString port: aPortNumber
	"Open a TLS socket stream to the given host and port and perform the TLS handshake."
	| secureStream |
	secureStream := self configureStream: (SecureSocketStream openConnectionToHostNamed: aHostString port: aPortNumber).
	secureStream sslConnectTo: aHostString.
	^ secureStream! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:33'!
openStreamToHost: aHostString port: aPortNumber
	"Open a plain TCP socket stream to the given host and port."
	^ self configureStream: (SocketStream openConnectionToHostNamed: aHostString port: aPortNumber)! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:34'!
readLine
	"Read one CRLF-terminated line from the server."
	^ stream nextLineCrLf! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:36'!
replyText: aReplyLinesCollection
	"Answer the reply lines joined for an error message."
	^ String streamContents: [:aStream |
		aReplyLinesCollection
			do: [:aLine | aStream nextPutAll: aLine]
			separatedBy: [aStream nextPutAll: ' / ']]! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:35'!
send: aString
	"Write aString plus CRLF to the server."
	stream nextPutAll: aString; crlf; flush! !

!SmtpClient methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:19:35'!
sendCommand: aCommandString
	"Send aCommandString and answer the server's (multi-line) reply."
	self send: aCommandString.
	^ self readReply! !

!SmtpMessage methodsFor: 'initialize-release' stamp: 'rc 6/Aug/2026 05:17:36'!
initializeFrom: aFromAddress to: aToCollection subject: aSubjectString text: aTextString attachments: anAttachmentCollection
	"Set the message fields; the date defaults to now."
	from := aFromAddress.
	to := self normalizedCollection: aToCollection.
	cc := OrderedCollection new.
	subject := aSubjectString.
	text := aTextString.
	attachments := anAttachmentCollection.
	date := DateAndTime now! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:38'!
attachments
	"Answer the collection of SmtpAttachments."
	^ attachments! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:37'!
cc
	"Answer the collection of Cc addresses."
	^ cc! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:37'!
cc: aCcCollection
	"Set the Cc addresses."
	cc := self normalizedCollection: aCcCollection! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:39'!
date
	"Answer the message date."
	^ date! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:36'!
from
	"Answer the sender address."
	^ from! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:39'!
recipients
	"Answer all recipient addresses (To plus Cc)."
	^ to, cc! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:38'!
subject
	"Answer the subject."
	^ subject! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:38'!
text
	"Answer the plain-text body."
	^ text! !

!SmtpMessage methodsFor: 'accessing' stamp: 'rc 6/Aug/2026 05:17:36'!
to
	"Answer the collection of To addresses."
	^ to! !

!SmtpMessage methodsFor: 'building' stamp: 'rc 6/Aug/2026 05:17:49'!
appendTextPartTo: anOutputStream boundary: aBoundaryString
	"Write the leading text/plain part of a multipart message."
	anOutputStream
		nextPutAll: '--', aBoundaryString; nextPutAll: String crlfString;
		nextPutAll: 'Content-Type: text/plain; charset=utf-8'; nextPutAll: String crlfString;
		nextPutAll: 'Content-Transfer-Encoding: quoted-printable'; nextPutAll: String crlfString;
		nextPutAll: String crlfString;
		nextPutAll: (self quotedPrintableEncode: text);
		nextPutAll: String crlfString;
		nextPutAll: String crlfString! !

!SmtpMessage methodsFor: 'building' stamp: 'rc 6/Aug/2026 05:17:50'!
headerFields
	"Answer the base RFC 5322 header (without Content-Type) as a String."
	^ String streamContents: [:aStream |
		aStream
			nextPutAll: 'From: ', (self encodedHeaderValue: from); nextPutAll: String crlfString;
			nextPutAll: 'To: ', (self encodedHeaderValue: (self joinAddresses: to)); nextPutAll: String crlfString;
			nextPutAll: 'Date: ', self rfc2822Date; nextPutAll: String crlfString;
			nextPutAll: 'Subject: ', (self encodedHeaderValue: subject); nextPutAll: String crlfString.
		cc notEmpty ifTrue: [
			aStream
				nextPutAll: 'Cc: ', (self encodedHeaderValue: (self joinAddresses: cc)); nextPutAll: String crlfString].
		aStream nextPutAll: 'MIME-Version: 1.0']! !

!SmtpMessage methodsFor: 'building' stamp: 'rc 6/Aug/2026 05:17:48'!
multipartSource
	"Answer the message source for a message with one or more attachments (multipart/mixed)."
	| boundary output |
	boundary := self newBoundary.
	output := WriteStream on: (String new: 2000).
	output
		nextPutAll: self headerFields; nextPutAll: String crlfString;
		nextPutAll: 'Content-Type: multipart/mixed; boundary="', boundary, '"'; nextPutAll: String crlfString;
		nextPutAll: String crlfString.
	self appendTextPartTo: output boundary: boundary.
	attachments do: [:attachment |
		output
			nextPutAll: '--', boundary; nextPutAll: String crlfString;
			nextPutAll: 'Content-Type: ', attachment contentType, '; name="', attachment fileName, '"'; nextPutAll: String crlfString;
			nextPutAll: 'Content-Transfer-Encoding: base64'; nextPutAll: String crlfString;
			nextPutAll: 'Content-Disposition: attachment; filename="', attachment fileName, '"'; nextPutAll: String crlfString;
			nextPutAll: String crlfString;
			nextPutAll: (self wrappedBase64Encode: attachment content);
			nextPutAll: String crlfString;
			nextPutAll: String crlfString].
	output nextPutAll: '--', boundary, '--'; nextPutAll: String crlfString.
	^ output contents! !

!SmtpMessage methodsFor: 'building' stamp: 'rc 6/Aug/2026 05:17:46'!
plainSource
	"Answer the message source for a text-only message."
	^ String streamContents: [:aStream |
		aStream
			nextPutAll: self headerFields; nextPutAll: String crlfString;
			nextPutAll: 'Content-Type: text/plain; charset=utf-8'; nextPutAll: String crlfString;
			nextPutAll: 'Content-Transfer-Encoding: quoted-printable'; nextPutAll: String crlfString;
			nextPutAll: String crlfString;
			nextPutAll: (self quotedPrintableEncode: text);
			nextPutAll: String crlfString]! !

!SmtpMessage methodsFor: 'building' stamp: 'rc 6/Aug/2026 05:17:45'!
rfc822Source
	"Answer the complete RFC 5322 message source with CRLF line endings, ready for the SMTP DATA phase."
	attachments isEmpty
		ifTrue: [^ self plainSource].
	^ self multipartSource! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:18:02'!
base64Encode: aContent
	"Answer aContent (a String or a ByteArray) as a single-line base64 string."
	| bytes |
	bytes := aContent isString
		ifTrue: [aContent asUtf8Bytes]
		ifFalse: [aContent].
	^ (Base64MimeConverter mimeEncode: bytes readStream multiLine: false) contents! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:17:55'!
encodedHeaderValue: aString
	"Answer aString as-is when pure ASCII, otherwise as an RFC 2047 UTF-8 base64 encoded word."
	(aString allSatisfy: [:character | character codePoint < 128])
		ifTrue: [^ aString].
	^ '=?UTF-8?B?', (self base64Encode: aString), '?='! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:17:56'!
joinAddresses: anAddressCollection
	"Answer the addresses joined into a comma-separated string."
	^ String streamContents: [:aStream |
		anAddressCollection do: [:anAddress | aStream nextPutAll: anAddress] separatedBy: [aStream nextPutAll: ', ']]! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:18:00'!
newBoundary
	"Answer a MIME boundary string unlikely to occur in the message content."
	^ 'CuismailBoundary', (UUID new asString copyReplaceAll: '-' with: '')! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:18:04'!
normalizedCollection: aCollection
	"Answer aCollection as a collection of addresses; a single address string is wrapped in an Array."
	^ aCollection isString
		ifTrue: [Array with: aCollection]
		ifFalse: [aCollection]! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:18:17'!
offsetString
	"Answer the UTC offset of the message date in RFC 2822 format like '+0200'."
	| sign totalMinutes magnitude padLength |
	sign := date offset totalSeconds < 0 ifTrue: ['-'] ifFalse: ['+'].
	totalMinutes := (date offset totalSeconds abs / 60) asInteger.
	magnitude := totalMinutes printString.
	padLength := (4 - magnitude size) max: 0.
	^ sign, (String new: padLength withAll: $0), magnitude! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:18:02'!
paddedHexFor: anInteger
	"Answer the two-digit uppercase hex representation of a byte."
	^ (anInteger < 16 ifTrue: ['0'] ifFalse: ['']), (anInteger printStringBase: 16) asUppercase! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:38:59'!
quotedPrintableEncode: aString
	"Encode aString as quoted-printable (UTF-8), wrapping lines at 76 characters.
	Printable ASCII (including space) is kept literal, '=' and non-ASCII bytes are encoded."
	| output lineLength |
	output := WriteStream on: (String new: aString size * 3).
	lineLength := 0.
	aString asUtf8Bytes do: [:byte |
		(byte = 13 or: [byte = 10])
			ifTrue: [output nextPut: (Character codePoint: byte). lineLength := 0]
			ifFalse: [
				| encodedByte |
				encodedByte := ((byte between: 32 and: 126) and: [byte ~= $= codePoint])
					ifTrue: [String with: (Character codePoint: byte)]
					ifFalse: ['=' , (self paddedHexFor: byte)].
				(lineLength + encodedByte size > 76)
					ifTrue: [output nextPutAll: '=', String crlfString. lineLength := 0].
				output nextPutAll: encodedByte.
				lineLength := lineLength + encodedByte size]].
	^ output contents! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:17:57'!
rfc2822Date
	"Answer the message date in RFC 2822 format, e.g. 'Wed, 06 Aug 2026 12:00:00 +0200'."
	| weekdays months |
	weekdays := #('Mon' 'Tue' 'Wed' 'Thu' 'Fri' 'Sat' 'Sun').
	months := #('Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec').
	^ String streamContents: [:aStream |
		aStream
			nextPutAll: (weekdays at: date dayOfWeek); nextPutAll: ', ';
			nextPutAll: (self twoDigit: date dayOfMonth); nextPutAll: ' ';
			nextPutAll: (months at: date monthIndex); nextPutAll: ' ';
			nextPutAll: date yearNumber printString; nextPutAll: ' ';
			nextPutAll: (self twoDigit: date hour24); nextPutAll: ':';
			nextPutAll: (self twoDigit: date minute); nextPutAll: ':';
			nextPutAll: (self twoDigit: date second); nextPutAll: ' ';
			nextPutAll: self offsetString]! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:17:58'!
twoDigit: anInteger
	"Answer anInteger as a two-digit (zero-padded) string."
	anInteger printString size < 2
		ifTrue: [^ '0', anInteger printString].
	^ anInteger printString! !

!SmtpMessage methodsFor: 'private' stamp: 'rc 6/Aug/2026 05:18:49'!
wrappedBase64Encode: aContent
	"Answer aContent as a base64 string with lines wrapped at 76 characters and CRLF line endings."
	| encoded output |
	encoded := self base64Encode: aContent.
	output := WriteStream on: (String new: encoded size + 8).
	1 to: encoded size by: 76 do: [:start |
		output
			nextPutAll: (encoded copyFrom: start to: ((start + 75) min: encoded size));
			nextPutAll: String crlfString].
	^ output contents! !

!SmtpMessage class methodsFor: 'instance creation' stamp: 'rc 6/Aug/2026 05:17:40'!
from: aFromAddress to: aToCollection subject: aSubjectString text: aTextString
	"Answer a text-only message addressed to the given recipients."
	^ self from: aFromAddress to: aToCollection subject: aSubjectString text: aTextString attachments: #()! !

!SmtpMessage class methodsFor: 'instance creation' stamp: 'rc 6/Aug/2026 05:17:40'!
from: aFromAddress to: aToCollection subject: aSubjectString text: aTextString attachments: anAttachmentCollection
	"Answer a message addressed to the given recipients with one or more attachments."
	^ self new
		initializeFrom: aFromAddress
		to: aToCollection
		subject: aSubjectString
		text: aTextString
		attachments: anAttachmentCollection! !