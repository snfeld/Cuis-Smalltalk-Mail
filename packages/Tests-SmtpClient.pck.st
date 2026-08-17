@From Cuis7.8 [latest update: #7977] on 6 August 2026 at 6:03:08 am'!
'Description '!
!provides: 'Tests-SmtpClient' 1 0!
SystemOrganization addCategory: #'Tests-SmtpClient'!


!classDefinition: #SmtpMockStream category: #'Tests-SmtpClient'!
Object subclass: #SmtpMockStream
	instanceVariableNames: 'outgoing incoming asciiFlag closedFlag timeoutValue'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-SmtpClient'!
!classDefinition: 'SmtpMockStream class' category: #'Tests-SmtpClient'!
SmtpMockStream class
	instanceVariableNames: ''!


!classDefinition: #SmtpClientParsingTest category: #'Tests-SmtpClient'!
TestCase subclass: #SmtpClientParsingTest
	instanceVariableNames: 'client stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-SmtpClient'!
!classDefinition: 'SmtpClientParsingTest class' category: #'Tests-SmtpClient'!
SmtpClientParsingTest class
	instanceVariableNames: ''!

!classDefinition: #SmtpClientSendingTest category: #'Tests-SmtpClient'!
TestCase subclass: #SmtpClientSendingTest
	instanceVariableNames: 'client stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-SmtpClient'!
!classDefinition: 'SmtpClientSendingTest class' category: #'Tests-SmtpClient'!
SmtpClientSendingTest class
	instanceVariableNames: ''!

!classDefinition: #SmtpClientStateTest category: #'Tests-SmtpClient'!
TestCase subclass: #SmtpClientStateTest
	instanceVariableNames: 'client'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-SmtpClient'!
!classDefinition: 'SmtpClientStateTest class' category: #'Tests-SmtpClient'!
SmtpClientStateTest class
	instanceVariableNames: ''!

!classDefinition: #SmtpClientTest category: #'Tests-SmtpClient'!
TestCase subclass: #SmtpClientTest
	instanceVariableNames: 'client stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-SmtpClient'!
!classDefinition: 'SmtpClientTest class' category: #'Tests-SmtpClient'!
SmtpClientTest class
	instanceVariableNames: ''!

!classDefinition: #SmtpMessageTest category: #'Tests-SmtpClient'!
TestCase subclass: #SmtpMessageTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-SmtpClient'!
!classDefinition: 'SmtpMessageTest class' category: #'Tests-SmtpClient'!
SmtpMessageTest class
	instanceVariableNames: ''!


!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:15'!
addLine: aString
	incoming addLast: aString.
	^ self! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:16'!
addLines: aCollection
	incoming addAll: aCollection.
	^ self! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:18'!
ascii
	asciiFlag := true.
	^ self! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:18'!
close
	closedFlag := true.
	^ self! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:19'!
configuredTimeout
	^ timeoutValue! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:17'!
crlf
	outgoing addLast: String crlfString.
	^ self! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:17'!
flush
	^ self! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:15'!
initialize
	outgoing := OrderedCollection new.
	incoming := OrderedCollection new.
	asciiFlag := false.
	closedFlag := false.
	timeoutValue := nil! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:19'!
isClosed
	^ closedFlag! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:16'!
nextLineCrLf
	incoming isEmpty ifTrue: [^ nil].
	^ incoming removeFirst! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:16'!
nextPutAll: aString
	outgoing addLast: aString.
	^ aString! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:20'!
sentLines
	^ String streamContents: [:aStream | outgoing do: [:each | aStream nextPutAll: each]]! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:18'!
timeout: anInteger
	timeoutValue := anInteger.
	^ self! !

!SmtpMockStream methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:19'!
wasConfiguredAscii
	^ asciiFlag! !

!SmtpMockStream methodsFor: 'testing' stamp: 'rc 6/Aug/2026 05:50:54'!
timeout
	^ timeoutValue! !


!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:33'!
setUp
	client := SmtpClient new.
	stream := SmtpMockStream new.
	client instVarNamed: 'stream' put: stream! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:41'!
testBase64EncodeBytes
	self assert: 'AQIDBA==' equals: (client base64Encode: #[1 2 3 4])! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:40'!
testBase64EncodeString
	self assert: 'dXNlcg==' equals: (client base64Encode: 'user')! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:37'!
testCheckReplyPassesPositiveReply
	self assert: (client checkReply: (OrderedCollection with: '250 2.1.0 OK')) first = '250 2.1.0 OK'! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:38'!
testCheckReplyRaisesOnErrorReply
	self should: [client checkReply: (OrderedCollection with: '550 5.1.1 unknown recipient')] raise: Error! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:48'!
testDotStuffNormalizesLineEndings
	| stuffed |
	stuffed := client dotStuff: 'Zeile 1', (String with: Character lf), 'Zeile 2'.
	self assert: (stuffed endsWith: 'Zeile 2', String crlfString).
	self assert: (stuffed occurrencesOf: Character cr) equals: 2! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:36'!
testIsPositiveReplyCode
	self assert: (client isPositiveReplyCode: 220).
	self assert: (client isPositiveReplyCode: 250).
	self assert: (client isPositiveReplyCode: 334).
	self assert: (client isPositiveReplyCode: 354).
	self deny: (client isPositiveReplyCode: 421).
	self deny: (client isPositiveReplyCode: 550)! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:34'!
testReadReplyReadsMultilineReply
	stream addLines: #('250-smtp.example.com' '250-SIZE 35882577' '250 AUTH LOGIN').
	self assert: 3 equals: (client readReply) size! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:33'!
testReadReplyReadsSingleLine
	stream addLine: '220 smtp.example.com ESMTP ready'.
	self assert: (OrderedCollection with: '220 smtp.example.com ESMTP ready') equals: (client readReply)! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:36'!
testReplyCodeAnswersThreeDigitCode
	self assert: 250 equals: (client replyCode: (OrderedCollection with: '250 2.1.0 OK')).
	self assert: 334 equals: (client replyCode: (OrderedCollection with: '334 UGFzc3dvcmQ6'))! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:42'!
testSupportsAuthentication
	client instVarNamed: 'capabilities' put: (OrderedCollection with: 'AUTH PLAIN LOGIN').
	self assert: client supportsAuthentication.
	client instVarNamed: 'capabilities' put: OrderedCollection new.
	self deny: client supportsAuthentication! !

!SmtpClientParsingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:41'!
testSupportsStartTls
	client instVarNamed: 'capabilities' put: (OrderedCollection with: 'STARTTLS').
	self assert: client supportsStartTls! !

!SmtpClientParsingTest methodsFor: 'tests' stamp: 'rc 6/Aug/2026 05:37:05'!
testDotStuffDoublesLeadingDots
	| stuffed |
	stuffed := client dotStuff: '.versteckt', String crlfString.
	self assert: ('..versteckt', String crlfString) equals: stuffed! !

!SmtpClientParsingTest methodsFor: 'tests' stamp: 'rc 6/Aug/2026 05:37:16'!
testReadReplyRaisesWhenConnectionCloses
	stream addLine: '220-foo'.
	self should: [client readReply] raise: Error! !

!SmtpClientSendingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:11'!
setUp
	client := SmtpClient new.
	stream := SmtpMockStream new.
	client instVarNamed: 'stream' put: stream! !

!SmtpClientSendingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:17'!
testSendMessageDotStuffsBody
	stream addLines: #('250 2.1.0 OK' '250 2.1.5 OK' '354 End data with <CR><LF>.<CR><LF>' '250 2.0.0 OK queued').
	client sendMailFrom: 'a@b.de' to: (Array with: 'x@y.de') subject: 'T' text: '.versteckt'.
	self assert: (stream sentLines includesSubString: '..versteckt', String crlfString)! !

!SmtpClientSendingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:12'!
testSendMessageSendsEnvelopeAndData
	stream addLines: #('250 2.1.0 OK' '250 2.1.5 OK' '354 End data with <CR><LF>.<CR><LF>' '250 2.0.0 OK queued').
	client sendMailFrom: 'sender@example.de' to: (Array with: 'receiver@example.de') subject: 'Hallo' text: 'Testnachricht'.
	self assert: (stream sentLines includesSubString: 'MAIL FROM:<sender@example.de>', String crlfString).
	self assert: (stream sentLines includesSubString: 'RCPT TO:<receiver@example.de>', String crlfString).
	self assert: (stream sentLines includesSubString: 'DATA', String crlfString).
	self assert: (stream sentLines includesSubString: 'Subject: Hallo', String crlfString).
	self assert: (stream sentLines includesSubString: 'Testnachricht').
	self assert: (stream sentLines endsWith: '.', String crlfString)! !

!SmtpClientSendingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:22:12'!
testSendMessageToMultipleRecipientsIncludesCc
	| message |
	stream addLines: #('250 2.1.0 OK' '250 2.1.5 OK' '250 2.1.5 OK' '250 2.1.5 OK' '354 End data with <CR><LF>.<CR><LF>' '250 2.0.0 OK queued').
	message := SmtpMessage from: 'a@b.de' to: (Array with: 'x@y.de') subject: 'T' text: 'Body'.
	message cc: (Array with: 'c@d.de').
	client sendMessage: message.
	self assert: (stream sentLines includesSubString: 'RCPT TO:<x@y.de>', String crlfString).
	self assert: (stream sentLines includesSubString: 'RCPT TO:<c@d.de>', String crlfString)! !

!SmtpClientSendingTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:16'!
testSendMessageWithAttachments
	| attachment |
	stream addLines: #('250 2.1.0 OK' '250 2.1.5 OK' '354 End data with <CR><LF>.<CR><LF>' '250 2.0.0 OK queued').
	attachment := SmtpAttachment fileName: 'd.bin' contentType: 'application/octet-stream' content: #[1 2 3 4].
	client sendMailFrom: 'a@b.de' to: (Array with: 'x@y.de') subject: 'T' text: 'Body' attachments: (Array with: attachment).
	self assert: (stream sentLines includesSubString: 'Content-Type: multipart/mixed;').
	self assert: (stream sentLines includesSubString: 'Content-Disposition: attachment; filename="d.bin"', String crlfString).
	self assert: (stream sentLines includesSubString: 'AQIDBA==', String crlfString).! !

!SmtpClientStateTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:24'!
setUp
	client := SmtpClient new! !

!SmtpClientStateTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:27'!
testCloseResetsStateAndCapabilities
	client instVarNamed: 'state' put: #authenticated.
	client instVarNamed: 'capabilities' put: (OrderedCollection with: 'AUTH LOGIN').
	client close.
	self deny: client isConnected.
	self assert: #disconnected equals: client state.
	self assert: (client capabilities isEmpty)! !

!SmtpClientStateTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:25'!
testInitialize
	self assert: #disconnected equals: client state.
	self assert: 60 equals: client timeout.
	self assert: nil equals: client stream.
	self assert: (client capabilities isEmpty)! !

!SmtpClientStateTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:26'!
testIsConnectedAfterAuthenticating
	client instVarNamed: 'state' put: #authenticated.
	self assert: client isConnected! !

!SmtpClientStateTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:26'!
testIsConnectedAfterConnecting
	client instVarNamed: 'state' put: #connected.
	self assert: client isConnected! !

!SmtpClientStateTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:25'!
testIsConnectedWhenDisconnected
	self deny: client isConnected! !

!SmtpClientStateTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:27'!
testTimeoutSetter
	client timeout: 30.
	self assert: 30 equals: client timeout! !

!SmtpClientTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:48'!
setUp
	client := SmtpClient new.
	stream := SmtpMockStream new.
	client instVarNamed: 'stream' put: stream! !

!SmtpClientTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:48'!
testEhloStoresCapabilities
	stream addLines: #('250-smtp.example.com' '250-SIZE 35882577' '250-STARTTLS' '250 AUTH PLAIN LOGIN').
	client ehlo.
	self assert: (client capabilities includes: 'STARTTLS').
	self assert: (client capabilities includes: 'AUTH PLAIN LOGIN').
	self assert: client supportsStartTls.
	self assert: client supportsAuthentication! !

!SmtpClientTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:51'!
testLoginRaisesOnFailedAuthentication
	stream addLines: #('334 VXNlcm5hbWU6' '334 UGFzc3dvcmQ6' '535 5.7.8 Authentication credentials invalid').
	self should: [client login: 'user' password: 'wrong'] raise: Error! !

!SmtpClientTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:50'!
testLoginSendsBase64Credentials
	stream addLines: #('334 VXNlcm5hbWU6' '334 UGFzc3dvcmQ6' '235 2.7.0 Authentication successful').
	client login: 'user' password: 'secret'.
	self assert: (stream sentLines includesSubString: 'AUTH LOGIN', String crlfString).
	self assert: (stream sentLines includesSubString: 'dXNlcg==', String crlfString).
	self assert: (stream sentLines includesSubString: 'c2VjcmV0', String crlfString)! !

!SmtpClientTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:49'!
testLoginSetsAuthenticatedState
	stream addLines: #('334 VXNlcm5hbWU6' '334 UGFzc3dvcmQ6' '235 2.7.0 Authentication successful').
	client login: 'user' password: 'secret'.
	self assert: #authenticated equals: client state! !

!SmtpClientTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:52'!
testSendCommandReadsMultilineReply
	stream addLines: #('250-smtp.example.com' '250 AUTH LOGIN').
	self assert: 2 equals: (client sendCommand: 'NOOP') size! !

!SmtpClientTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:20:52'!
testSendCommandSendsLineWithCrlf
	stream addLine: '250 2.0.0 OK'.
	client sendCommand: 'NOOP'.
	self assert: 'NOOP', String crlfString equals: (stream sentLines)! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:22:26'!
countSubstring: aSubString in: aString
	"Answer the number of non-overlapping occurrences of aSubString in aString."
	| count index |
	count := 0.
	index := 1.
	[index := aString indexOfSubCollection: aSubString startingAt: index.
	index > 0] whileTrue: [
		count := count + 1.
		index := index + aSubString size].
	^ count! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:29'!
testAttachmentIsBase64Encoded
	| source |
	source := (SmtpMessage
		from: 'a@b.de'
		to: (Array with: 'c@d.de')
		subject: 'T'
		text: 'Body'
		attachments: (Array with: (SmtpAttachment fileName: 'd.bin' contentType: 'application/octet-stream' content: #[1 2 3 4]))) rfc822Source.
	self assert: (source includesSubString: 'AQIDBA==', String crlfString).
	self assert: (source includesSubString: 'Content-Transfer-Encoding: base64', String crlfString)! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:26'!
testBodyIsQuotedPrintableEncoded
	| source |
	source := (SmtpMessage
		from: 'a@b.de'
		to: (Array with: 'c@d.de')
		subject: 'T'
		text: (self utf8String: #[71 114 195 188 195 159 101])) rfc822Source.
	self assert: (source includesSubString: 'Gr=C3=BC=C3=9Fe').! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:22:27'!
testMultipleAttachments
	| source |
	source := (SmtpMessage
		from: 'a@b.de'
		to: (Array with: 'c@d.de')
		subject: 'T'
		text: 'Body'
		attachments: (Array
			with: (SmtpAttachment fileName: 'one.txt' contentType: 'text/plain' content: 'a')
			with: (SmtpAttachment fileName: 'two.bin' contentType: 'application/octet-stream' content: #[2 2 2]))) rfc822Source.
	self assert: (source includesSubString: 'filename="one.txt"', String crlfString).
	self assert: (source includesSubString: 'filename="two.bin"', String crlfString).
! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:24'!
testNonAsciiSubjectIsRfc2047Encoded
	| source subjectBytes expected |
	subjectBytes := #[66 101 116 114 101 102 102 32 71 114 195 188 195 159 101].
	source := (SmtpMessage
		from: 'a@b.de'
		to: (Array with: 'c@d.de')
		subject: (self utf8String: subjectBytes)
		text: 'x') rfc822Source.
	expected := (Base64MimeConverter mimeEncode: subjectBytes readStream multiLine: false) contents.
	self assert: (source includesSubString: 'Subject: =?UTF-8?B?', expected, '?=').! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:34'!
testNormalizesSingleRecipientString
	| message |
	message := SmtpMessage
		from: 'a@b.de'
		to: 'single@x.de'
		subject: 'T'
		text: 'x'.
	self assert: 1 equals: message recipients size.
	self assert: 'single@x.de' equals: message recipients first! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:22'!
testPlainSourceContainsHeadersAndBody
	| source |
	source := (SmtpMessage
		from: 'sender@example.de'
		to: (Array with: 'receiver@example.de')
		subject: 'Hallo'
		text: 'Eine Testnachricht') rfc822Source.
	self assert: (source includesSubString: 'From: sender@example.de', String crlfString).
	self assert: (source includesSubString: 'To: receiver@example.de', String crlfString).
	self assert: (source includesSubString: 'Subject: Hallo', String crlfString).
	self assert: (source includesSubString: 'MIME-Version: 1.0').
	self assert: (source includesSubString: 'Content-Type: text/plain; charset=utf-8').
	self assert: (source includesSubString: 'Eine Testnachricht')! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:23'!
testPlainSourceHasCrlfLineEndings
	| source |
	source := (SmtpMessage
		from: 'a@b.de'
		to: (Array with: 'c@d.de')
		subject: 'T'
		text: 'x') rfc822Source.
	self assert: (source occurrencesOf: Character lf) equals: (source occurrencesOf: Character cr).
	self assert: (source includesSubString: String crlfString)! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:31'!
testRecipientsIncludeToAndCc
	| message |
	message := SmtpMessage
		from: 'a@b.de'
		to: (Array with: 'x@y.de')
		subject: 'T'
		text: 'Body'.
	message cc: (Array with: 'c@d.de').
	self assert: 2 equals: message recipients size.
	self assert: (message recipients includes: 'c@d.de')! !

!SmtpMessageTest methodsFor: 'Tests-SmtpClient' stamp: 'rc 6/Aug/2026 05:21:20'!
utf8String: aByteArray
	"Answer the Unicode string whose UTF-8 encoding is aByteArray."
	^ UnicodeString fromUtf8Bytes: aByteArray! !

!SmtpMessageTest methodsFor: 'tests' stamp: 'rc 6/Aug/2026 05:37:51'!
testDateIsRfc2822Formatted
	| source line |
	source := (SmtpMessage
		from: 'a@b.de'
		to: (Array with: 'c@d.de')
		subject: 'T'
		text: 'x') rfc822Source.
	line := (source lines detect: [:aLine | aLine beginsWith: 'Date: ']).
	self assert: 37 equals: line size.
	self assert: ((7 to: 9) allSatisfy: [:i | (line at: i) isLetter]).
	self assert: (line at: 10) = $,.
	self assert: (line at: 11) = Character space.
	self assert: ((12 to: 13) allSatisfy: [:i | (line at: i) isDigit]).
	self assert: (line at: 14) = Character space.
	self assert: ((15 to: 17) allSatisfy: [:i | (line at: i) isLetter]).
	self assert: (line at: 18) = Character space.
	self assert: ((19 to: 22) allSatisfy: [:i | (line at: i) isDigit]).
	self assert: (line at: 23) = Character space.
	self assert: ((24 to: 31) allSatisfy: [:i | (line at: i) isDigit or: [(line at: i) = $:]]).
	self assert: (line at: 32) = Character space.
	self assert: (((line at: 33) = $+) or: [(line at: 33) = $-]).
	self assert: ((34 to: 37) allSatisfy: [:i | (line at: i) isDigit])! !

!SmtpMessageTest methodsFor: 'tests' stamp: 'rc 6/Aug/2026 05:38:29'!
testMultipartSourceHasBoundaryAndParts
	| source attachment |
	attachment := SmtpAttachment fileName: 'doc.txt' contentType: 'text/plain' content: 'abc'.
	source := (SmtpMessage
		from: 'a@b.de'
		to: (Array with: 'c@d.de')
		subject: 'T'
		text: 'Body'
		attachments: (Array with: attachment)) rfc822Source.
	self assert: (source includesSubString: 'Content-Type: multipart/mixed; boundary="CuismailBoundary').
	self assert: (source includesSubString: '--CuismailBoundary').
	self assert: (source endsWith: '--', String crlfString).
	self assert: (source includesSubString: 'Content-Type: text/plain; name="doc.txt"', String crlfString).
	self assert: (source includesSubString: 'Content-Disposition: attachment; filename="doc.txt"', String crlfString)! !
