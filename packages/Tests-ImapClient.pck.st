'From Cuis7.8 [latest update: #7977] on 9 August 2026 at 5:47:17 pm'!
'Description '!
!provides: 'Tests-ImapClient' 1 3!
SystemOrganization addCategory: #'Tests-ImapClient'!


!classDefinition: #ImapMockStream category: #'Tests-ImapClient'!
Object subclass: #ImapMockStream
	instanceVariableNames: 'outgoing incoming literalBuffer literalPosition timeoutValue asciiFlag closedFlag'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapMockStream class' category: #'Tests-ImapClient'!
ImapMockStream class
	instanceVariableNames: ''!

!classDefinition: #ImapClientFetchTest category: #'Tests-ImapClient'!
TestCase subclass: #ImapClientFetchTest
	instanceVariableNames: 'client stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapClientFetchTest class' category: #'Tests-ImapClient'!
ImapClientFetchTest class
	instanceVariableNames: ''!

!classDefinition: #ImapClientMailboxesTest category: #'Tests-ImapClient'!
TestCase subclass: #ImapClientMailboxesTest
	instanceVariableNames: 'client stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapClientMailboxesTest class' category: #'Tests-ImapClient'!
ImapClientMailboxesTest class
	instanceVariableNames: ''!

!classDefinition: #ImapClientMessageManagementTest category: #'Tests-ImapClient'!
TestCase subclass: #ImapClientMessageManagementTest
	instanceVariableNames: 'client stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapClientMessageManagementTest class' category: #'Tests-ImapClient'!
ImapClientMessageManagementTest class
	instanceVariableNames: ''!

!classDefinition: #ImapClientMailboxManagementTest category: #'Tests-ImapClient'!
ImapClientMessageManagementTest subclass: #ImapClientMailboxManagementTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapClientMailboxManagementTest class' category: #'Tests-ImapClient'!
ImapClientMailboxManagementTest class
	instanceVariableNames: ''!

!classDefinition: #ImapClientParsingTest category: #'Tests-ImapClient'!
TestCase subclass: #ImapClientParsingTest
	instanceVariableNames: 'client'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapClientParsingTest class' category: #'Tests-ImapClient'!
ImapClientParsingTest class
	instanceVariableNames: ''!

!classDefinition: #ImapClientProtocolTest category: #'Tests-ImapClient'!
TestCase subclass: #ImapClientProtocolTest
	instanceVariableNames: 'client stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapClientProtocolTest class' category: #'Tests-ImapClient'!
ImapClientProtocolTest class
	instanceVariableNames: ''!

!classDefinition: #ImapClientStateTest category: #'Tests-ImapClient'!
TestCase subclass: #ImapClientStateTest
	instanceVariableNames: 'client'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapClientStateTest class' category: #'Tests-ImapClient'!
ImapClientStateTest class
	instanceVariableNames: ''!

!classDefinition: #ImapClientTest category: #'Tests-ImapClient'!
TestCase subclass: #ImapClientTest
	instanceVariableNames: 'client'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapClientTest class' category: #'Tests-ImapClient'!
ImapClientTest class
	instanceVariableNames: ''!

!classDefinition: #ImapMessageTest category: #'Tests-ImapClient'!
TestCase subclass: #ImapMessageTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-ImapClient'!
!classDefinition: 'ImapMessageTest class' category: #'Tests-ImapClient'!
ImapMessageTest class
	instanceVariableNames: ''!


!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
addLine: aString
	incoming addLast: aString.
	^ self
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
addLines: aCollection
	incoming addAll: aCollection.
	^ self
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
ascii
	asciiFlag := true.
	^ self
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
close
	closedFlag := true.
	^ self
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
configuredTimeout
	^ timeoutValue
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
crlf
	outgoing addLast: String crlfString.
	^ self
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
flush
	"Nothing to flush."
	^ self
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
initialize
	outgoing := OrderedCollection new.
	incoming := OrderedCollection new.
	literalBuffer := String new.
	literalPosition := 1.
	timeoutValue := nil.
	asciiFlag := false.
	closedFlag := false
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
isClosed
	^ closedFlag
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
literalBytes: aString
	literalBuffer := literalBuffer, aString.
	^ self
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
next: anInteger
	| result |
	result := String new writeStream.
	anInteger timesRepeat: [
		literalPosition <= literalBuffer size ifTrue: [
			result nextPut: (literalBuffer at: literalPosition).
			literalPosition := literalPosition + 1]].
	^ result contents
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
nextLineCrLf
	incoming isEmpty ifTrue: [^ nil].
	^ incoming removeFirst
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
nextPutAll: aString
	outgoing addLast: aString.
	^ aString
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
sentLines
	^ String streamContents: [:aStream | outgoing do: [:each | aStream nextPutAll: each]]
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
timeout: anInteger
	timeoutValue := anInteger.
	^ self
! !

!ImapMockStream methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
wasConfiguredAscii
	^ asciiFlag
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
setUp
	client := ImapClient new.
	stream := ImapMockStream new.
	client instVarNamed: 'stream' put: stream
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testFetchMessage
	stream addLine: '* 1 FETCH (BODY[] {5}'.
	stream literalBytes: 'Hello'.
	stream addLine: ')'.
	stream addLine: 'a1 OK FETCH completed'.
	self assert: 'Hello' equals: (client fetchMessage: 1).
	self assert: 'a1 FETCH 1 BODY[]' , String crlfString equals: stream sentLines
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testFetchMessageHeader
	stream addLine: '* 1 FETCH (BODY[HEADER] {5}'.
	stream literalBytes: 'Hello'.
	stream addLine: ')'.
	stream addLine: 'a1 OK FETCH completed'.
	self assert: 'Hello' equals: (client fetchMessageHeader: 1)
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 5/Aug/2026 18:28:59'!
testFetchMessageStructure
	| raw message |
	raw := 'Subject: Hallo', String crlfString,
		'Content-Type: text/plain; charset=utf-8', String crlfString,
		String crlfString,
		'Hallo Welt'.
	stream addLine: '* 1 FETCH (BODY[] {', raw size printString, '}'.
	stream literalBytes: raw.
	stream addLine: ')'.
	stream addLine: 'a1 OK FETCH completed'.
	message := client fetchMessageStructure: 1.
	self assert: 'Hallo' equals: message subject.
	self assert: 'Hallo Welt' equals: message body! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testFetchMessagesFromTo
	stream addLine: '* 1 FETCH (BODY[] {2}'.
	stream literalBytes: 'Hi'.
	stream addLine: ')'.
	stream addLine: 'a1 OK FETCH completed'.
	stream addLine: '* 2 FETCH (BODY[] {5}'.
	stream literalBytes: 'Hello'.
	stream addLine: ')'.
	stream addLine: 'a2 OK FETCH completed'.
	self assert: (OrderedCollection with: 'Hi' with: 'Hello') equals: (client fetchMessagesFrom: 1 to: 2)
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testFetchUsing
	stream addLine: '* 1 FETCH (BODY[HEADER] {5}'.
	stream literalBytes: 'Hello'.
	stream addLine: ')'.
	stream addLine: 'a1 OK FETCH completed'.
	self assert: 'Hello' equals: (client fetch: 1 using: 'BODY[HEADER]')
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadFetchLineAppendsLiteral
	| result |
	stream literalBytes: 'Hello'.
	result := WriteStream on: String new.
	self assert: (client readFetchLine: '* 1 FETCH (BODY[] {5}' forTag: 'a1' into: result).
	self assert: 'Hello' equals: result contents
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadFetchLineRaisesOnNil
	self should: [client readFetchLine: nil forTag: 'a1' into: (WriteStream on: String new)] raise: Error
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadFetchLineStopsAtTaggedResponse
	| result |
	result := WriteStream on: String new.
	self deny: (client readFetchLine: 'a1 OK FETCH completed' forTag: 'a1' into: result).
	self assert: '' equals: result contents
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadLiteralIfPresentIn
	stream literalBytes: 'Hello'.
	self assert: '* 1 FETCH {5}' , Character cr asString , 'Hello' equals: (client readLiteralIfPresentIn: '* 1 FETCH {5}')
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadLiteralIfPresentInWithoutLiteral
	self assert: '* 1 FETCH (BODY[])' equals: (client readLiteralIfPresentIn: '* 1 FETCH (BODY[])')
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadResponseLineAppendsLiteral
	| lines |
	stream literalBytes: 'Hello'.
	lines := OrderedCollection new.
	self assert: (client readResponseLine: '* 12 FETCH (BODY[] {5}' forTag: 'a1' into: lines).
	self assert: (OrderedCollection with: '* 12 FETCH (BODY[] {5}' , Character cr asString , 'Hello') equals: lines
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadResponseLineCollectsUntagged
	| lines |
	lines := OrderedCollection new.
	self assert: (client readResponseLine: '* LIST () "/" Drafts' forTag: 'a1' into: lines).
	self assert: (OrderedCollection with: '* LIST () "/" Drafts') equals: lines
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadResponseLineIgnoresContinuationAndEmpty
	| lines |
	lines := OrderedCollection new.
	self assert: (client readResponseLine: '' forTag: 'a1' into: lines).
	self assert: (client readResponseLine: '+ ready for literal' forTag: 'a1' into: lines).
	self assert: OrderedCollection new equals: lines
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadResponseLineRaisesOnUnexpected
	self should: [client readResponseLine: 'bogus line' forTag: 'a1' into: OrderedCollection new] raise: Error
! !

!ImapClientFetchTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadResponseLineStopsAtTaggedResponse
	| lines |
	lines := OrderedCollection new.
	self deny: (client readResponseLine: 'a1 OK LIST completed' forTag: 'a1' into: lines).
	self assert: OrderedCollection new equals: lines
! !

!ImapClientMailboxesTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
setUp
	client := ImapClient new.
	stream := ImapMockStream new.
	client instVarNamed: 'stream' put: stream
! !

!ImapClientMailboxesTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testListMailboxes
	stream addLines: #('* LIST (\HasNoChildren) "/" "INBOX"' '* LIST (\HasNoChildren) "/" "Trash"' 'a1 OK LIST completed').
	self assert: (OrderedCollection with: 'INBOX' with: 'Trash') equals: client listMailboxes
! !

!ImapClientMailboxesTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testListMailboxesIgnoresNonListLines
	stream addLines: #('* 3 EXISTS' '* LIST () "/" Drafts' 'a1 OK LIST completed').
	self assert: (OrderedCollection with: 'Drafts') equals: client listMailboxes
! !

!ImapClientMailboxesTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testSelectMailbox
	stream addLine: 'a1 OK SELECT completed'.
	self assert: 'INBOX' equals: (client selectMailbox: 'INBOX').
	self assert: 'INBOX' equals: client mailbox.
	self assert: 'a1 SELECT "INBOX"' , String crlfString equals: stream sentLines
! !

!ImapClientMessageManagementTest methodsFor: 'running' stamp: 'rc 8/Aug/2026 23:12:19'!
setUp
	client := ImapClient new.
	stream := ImapMockStream new.
	client instVarNamed: 'stream' put: stream! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:26'!
testCapabilityTokensFromLine
	self assert: (OrderedCollection with: 'IMAP4' with: 'MOVE') equals:
		(client capabilityTokensFromLine: '* CAPABILITY IMAP4 MOVE')! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:34'!
testCapabilityTokensFromLineRejectsOtherLines
	self assert: (OrderedCollection new) equals: (client capabilityTokensFromLine: '* 3 EXISTS')! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:41'!
testDeleteMessageSetsDeletedFlag
	stream addLine: 'a1 OK STORE completed'.
	client deleteMessage: 7.
	self assert: 'a1 STORE 7 +FLAGS.SILENT (\Deleted)' , String crlfString equals: stream sentLines! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:45'!
testExpungeAnswersRemovedSequenceNumbers
	stream addLines: #('* 7 EXPUNGE' '* 2 EXPUNGE' 'a1 OK EXPUNGE completed').
	self assert: (OrderedCollection with: 7 with: 2) equals: client expunge.
	self assert: 'a1 EXPUNGE' , String crlfString equals: stream sentLines! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:49'!
testExpungeWithoutRemovalsAnswersEmptyCollection
	stream addLine: 'a1 OK EXPUNGE completed'.
	self assert: (OrderedCollection new) equals: client expunge! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:23'!
testFetchCapabilities
	stream addLines: #('* CAPABILITY IMAP4rev1 MOVE UIDPLUS' 'a1 OK CAPABILITY completed').
	client fetchCapabilities.
	self assert: (OrderedCollection with: 'IMAP4rev1' with: 'MOVE' with: 'UIDPLUS') equals: client capabilities.
	self assert: 'a1 CAPABILITY' , String crlfString equals: stream sentLines! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:57'!
testMoveMessageFallsBackWithoutMoveSupport
	stream addLines: #('a1 OK COPY completed' 'a2 OK STORE completed' '* 3 EXPUNGE' 'a3 OK EXPUNGE completed').
	client moveMessage: 3 toMailbox: 'Archiv'.
	self assert: 'a1 COPY 3 "Archiv"' , String crlfString,
		'a2 STORE 3 +FLAGS.SILENT (\Deleted)', String crlfString,
		'a3 EXPUNGE', String crlfString equals: stream sentLines! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:52'!
testMoveMessageUsesMoveWhenSupported
	client instVarNamed: 'capabilities' put: (OrderedCollection with: 'MOVE').
	stream addLine: 'a1 OK MOVE completed'.
	client moveMessage: 5 toMailbox: 'Trash'.
	self assert: 'a1 MOVE 5 "Trash"' , String crlfString equals: stream sentLines! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:13:00'!
testSequenceNumberFromExpungeLine
	self assert: 3 equals: (client sequenceNumberFromExpungeLine: '* 3 EXPUNGE')
	! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:13:04'!
testSequenceNumberFromExpungeLineRejectsOtherLines
	self assert: nil equals: (client sequenceNumberFromExpungeLine: '* 3 EXISTS').
	self assert: nil equals: (client sequenceNumberFromExpungeLine: 'a1 OK EXPUNGE completed')! !

!ImapClientMessageManagementTest methodsFor: 'tests' stamp: 'rc 8/Aug/2026 23:12:37'!
testSupportsMove
	client instVarNamed: 'capabilities' put: (OrderedCollection with: 'IMAP4rev1' with: 'MOVE').
	self assert: client supportsMove.
	client instVarNamed: 'capabilities' put: (OrderedCollection with: 'IMAP4rev1').
	self deny: client supportsMove! !

!ImapClientMailboxManagementTest methodsFor: 'running' stamp: 'rc 9/Aug/2026 17:46:00'!
setUp
	client := ImapClient new.
	stream := ImapMockStream new.
	client instVarNamed: 'stream' put: stream! !

!ImapClientMailboxManagementTest methodsFor: 'tests' stamp: 'rc 9/Aug/2026 17:46:20'!
testCommandsSequenceOnSameClient
	stream addLines: #('a1 OK CREATE completed' 'a2 OK RENAME completed' 'a3 OK DELETE completed').
	client createMailbox: 'Neu'.
	client renameMailbox: 'Neu' toMailbox: 'Umbenannt'.
	client deleteMailbox: 'Umbenannt'.
	self assert: 'a1 CREATE "Neu"', String crlfString,
		'a2 RENAME "Neu" "Umbenannt"', String crlfString,
		'a3 DELETE "Umbenannt"', String crlfString equals: stream sentLines! !

!ImapClientMailboxManagementTest methodsFor: 'tests' stamp: 'rc 9/Aug/2026 17:46:03'!
testCreateMailbox
	stream addLine: 'a1 OK CREATE completed'.
	self assert: 'Neu' equals: (client createMailbox: 'Neu').
	self assert: 'a1 CREATE "Neu"', String crlfString equals: stream sentLines! !

!ImapClientMailboxManagementTest methodsFor: 'tests' stamp: 'rc 9/Aug/2026 17:46:06'!
testCreateMailboxWithSpacesQuotesTheName
	stream addLine: 'a1 OK CREATE completed'.
	client createMailbox: 'Neuer Ordner'.
	self assert: 'a1 CREATE "Neuer Ordner"', String crlfString equals: stream sentLines! !

!ImapClientMailboxManagementTest methodsFor: 'tests' stamp: 'rc 9/Aug/2026 17:46:16'!
testDeleteMailbox
	stream addLine: 'a1 OK DELETE completed'.
	self assert: 'Papierkorb' equals: (client deleteMailbox: 'Papierkorb').
	self assert: 'a1 DELETE "Papierkorb"', String crlfString equals: stream sentLines! !

!ImapClientMailboxManagementTest methodsFor: 'tests' stamp: 'rc 9/Aug/2026 17:46:41'!
testDeleteMissingMailboxRaisesServerError
	stream addLine: 'a1 NO [NONEXISTENT] Mailbox does not exist'.
	self should: [client deleteMailbox: 'GibtEsNicht'] raise: Error withMessageText: 'IMAP NO: a1 NO [NONEXISTENT] Mailbox does not exist'! !

!ImapClientMailboxManagementTest methodsFor: 'tests' stamp: 'rc 9/Aug/2026 17:46:13'!
testMoveMailboxIntoTargetParentFolder
	stream addLine: 'a1 OK RENAME completed'.
	self assert: 'Eltern/Ordner' equals: (client renameMailbox: 'Ordner' toMailbox: 'Eltern/Ordner').
	self assert: 'a1 RENAME "Ordner" "Eltern/Ordner"', String crlfString equals: stream sentLines! !

!ImapClientMailboxManagementTest methodsFor: 'tests' stamp: 'rc 9/Aug/2026 17:46:09'!
testRenameMailbox
	stream addLine: 'a1 OK RENAME completed'.
	self assert: 'Umbenannt' equals: (client renameMailbox: 'Alt' toMailbox: 'Umbenannt').
	self assert: 'a1 RENAME "Alt" "Umbenannt"', String crlfString equals: stream sentLines! !


!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
setUp
	client := ImapClient new
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testCheckStatusOk
	self shouldnt: [client checkStatus: 'a1 OK LOGIN done'] raise: Error
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testCheckStatusRaisesOnBad
	self should: [client checkStatus: 'a1 BAD unknown command'] raise: Error withMessageText: 'IMAP BAD: a1 BAD unknown command'
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testCheckStatusRaisesOnMalformed
	self should: [client checkStatus: 'a1'] raise: Error
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testCheckStatusRaisesOnNo
	self should: [client checkStatus: 'a1 NO invalid password'] raise: Error withMessageText: 'IMAP NO: a1 NO invalid password'
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testCheckStatusRaisesOnUnexpected
	self should: [client checkStatus: 'a1 PREAUTH ready'] raise: Error
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testIsContinuationRequest
	self assert: (client isContinuationRequest: '+ ready for literal').
	self deny: (client isContinuationRequest: '* 3 EXISTS').
	self deny: (client isContinuationRequest: '')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testIsListLine
	self assert: (client isListLine: '* LIST (\HasChildren) "/" "INBOX"').
	self deny: (client isListLine: '* 3 EXISTS')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testIsTaggedLineForTag
	self assert: (client isTaggedLine: 'a1 OK LOGIN done' forTag: 'a1')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testIsTaggedLineRejectsOtherTag
	self deny: (client isTaggedLine: 'a1 OK LOGIN done' forTag: 'a2')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testIsUntaggedLine
	self assert: (client isUntaggedLine: '* 3 EXISTS').
	self deny: (client isUntaggedLine: 'a1 OK LOGIN done').
	self deny: (client isUntaggedLine: '')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testLiteralSizeFromLine
	self assert: 5 equals: (client literalSizeFromLine: '* 1 FETCH (BODY[] {5}')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testLiteralSizeFromLineWithoutLiteral
	self assert: nil equals: (client literalSizeFromLine: '* 1 FETCH (BODY[])')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testMailboxNameFromListLine
	self assert: 'INBOX' equals: (client mailboxNameFromListLine: '* LIST (\HasNoChildren) "/" "INBOX"')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testMailboxNameFromListLineUnquoted
	self assert: 'Drafts' equals: (client mailboxNameFromListLine: '* LIST () "/" Drafts')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testQuoteArg
	self assert: '"inbox"' equals: (client quoteArg: 'inbox')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testQuoteArgEscapesBackslash
	self assert: '"a\\b"' equals: (client quoteArg: 'a\b')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testQuoteArgEscapesDoubleQuote
	self assert: '"a\"b"' equals: (client quoteArg: 'a"b')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testTokensIn
	self assert: (OrderedCollection with: '*' with: 'LIST' with: '()' with: '"/"' with: 'Drafts') equals: (client tokensIn: '* LIST () "/" Drafts')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testTokensInEmpty
	self assert: OrderedCollection new equals: (client tokensIn: '')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testTokensInListResponseWithoutDuplicates
	self assert: (OrderedCollection with: '*' with: 'LIST' with: '(\HasNoChildren)' with: '"/"' with: '"INBOX"') equals: (client tokensIn: '* LIST (\HasNoChildren) "/" "INBOX"')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testTokensInPreservesQuotedSpaces
	self assert: (OrderedCollection with: '"Inbox sub"' with: 'folder') equals: (client tokensIn: '"Inbox sub" folder')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testUnquote
	self assert: 'inbox' equals: (client unquote: '"inbox"')
! !

!ImapClientParsingTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testUnquoteLeavesUnquoted
	self assert: 'inbox' equals: (client unquote: 'inbox')
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
setUp
	client := ImapClient new.
	stream := ImapMockStream new.
	client instVarNamed: 'stream' put: stream
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testCloseClosesStreamAndResetsState
	client instVarNamed: 'state' put: #connected.
	client instVarNamed: 'mailbox' put: 'INBOX'.
	client close.
	self assert: stream isClosed.
	self deny: client isConnected.
	self assert: nil equals: client stream.
	self assert: nil equals: client mailbox
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testConfigureStream
	client timeout: 30.
	self assert: (client configureStream: stream) == stream.
	self assert: stream wasConfiguredAscii.
	self assert: 30 equals: stream configuredTimeout
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testLoginSetsAuthenticatedState
	stream addLine: 'a1 OK LOGIN completed'.
	self assert: (client login: 'user' password: 'secret').
	self assert: #authenticated equals: client state.
	self assert: 'a1 LOGIN "user" "secret"' , String crlfString equals: stream sentLines
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testLogoutSendsLogoutAndCloses
	client instVarNamed: 'state' put: #connected.
	stream addLine: 'a1 OK LOGOUT completed'.
	client logout.
	self assert: 'a1 LOGOUT' , String crlfString equals: stream sentLines.
	self assert: stream isClosed.
	self deny: client isConnected
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testLogoutWhenDisconnectedOnlyCloses
	client logout.
	self assert: stream isClosed.
	self assert: '' equals: stream sentLines
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadGreeting
	stream addLines: #('* OK [CAPABILITY IMAP4rev1] Server ready' 'a1 OK NOOP completed').
	self assert: '* OK [CAPABILITY IMAP4rev1] Server ready' equals: client readGreeting
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadGreetingWithoutGreetingRaises
	stream addLine: 'a1 OK NOOP completed'.
	self should: [client readGreeting] raise: Error
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadLine
	stream addLine: '* OK ready'.
	self assert: '* OK ready' equals: client readLine
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testReadLineWhenStreamClosed
	self assert: nil equals: client readLine
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testSendCommandCollectsUntaggedLines
	stream addLines: #('* LIST () "/" Drafts' 'a1 OK LIST completed').
	self assert: (OrderedCollection with: '* LIST () "/" Drafts') equals: (client sendCommand: 'LIST "" "*"')
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testSendCommandRaisesOnBad
	stream addLine: 'a1 BAD unknown command'.
	self should: [client sendCommand: 'BOGUS'] raise: Error
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testSendCommandRaisesOnNo
	stream addLine: 'a1 NO LOGIN failed'.
	self should: [client sendCommand: 'LOGIN user secret'] raise: Error withMessageText: 'IMAP NO: a1 NO LOGIN failed'
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testSendCommandUsesSequentialTags
	stream addLine: 'a1 OK one completed'.
	client sendCommand: 'NOOP'.
	stream addLine: 'a2 OK two completed'.
	client sendCommand: 'NOOP'.
	self assert: 'a1 NOOP' , String crlfString , 'a2 NOOP' , String crlfString equals: stream sentLines
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testSendCommandWithOnlyTaggedOk
	stream addLine: 'a1 OK LOGOUT completed'.
	self assert: OrderedCollection new equals: (client sendCommand: 'LOGOUT')
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testSendWritesLineWithCrlf
	client send: 'CAPABILITY'.
	self assert: 'CAPABILITY' , String crlfString equals: stream sentLines
! !

!ImapClientProtocolTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testStreamAccessor
	self assert: stream == client stream
! !

!ImapClientStateTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
setUp
	client := ImapClient new
! !

!ImapClientStateTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testInitialize
	self assert: #disconnected equals: client state.
	self assert: 60 equals: client timeout.
	self assert: nil equals: client mailbox.
	self assert: nil equals: client stream
! !

!ImapClientStateTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testIsConnectedAfterAuthenticating
	client instVarNamed: 'state' put: #authenticated.
	self assert: client isConnected
! !

!ImapClientStateTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testIsConnectedAfterConnecting
	client instVarNamed: 'state' put: #connected.
	self assert: client isConnected
! !

!ImapClientStateTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testIsConnectedWhenDisconnected
	self deny: client isConnected
! !

!ImapClientStateTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testNextTag
	self assert: 'a1' equals: client nextTag.
	self assert: 'a2' equals: client nextTag
! !

!ImapClientStateTest methodsFor: 'Tests-ImapClient' stamp: 'rc 1/Aug/2026 00:48:56'!
testTimeoutSetter
	client timeout: 30.
	self assert: 30 equals: client timeout
! !

!ImapClientTest methodsFor: 'running' stamp: 'rc 1/Aug/2026 12:20:55'!
setUp
	super setUp.
	client := ImapClient new! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:06'!
testCheckStatusAcceptsOk
	self assert: (client checkStatus: 'a1 OK completed') == client! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:07'!
testCheckStatusRaisesErrorOnNo
	self should: [client checkStatus: 'a1 NO [AUTHENTICATIONFAILED] invalid credentials'] raise: Error! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:06'!
testIsContinuationRequest
	self assert: (client isContinuationRequest: '+ ready for next command').
	self deny: (client isContinuationRequest: '* 1 EXISTS').
	self deny: (client isContinuationRequest: '')! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:03'!
testIsListLine
	self assert: (client isListLine: '* LIST () "/" INBOX').
	self deny: (client isListLine: '* 1 EXISTS')! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:02'!
testIsTaggedLineForTag
	self assert: (client isTaggedLine: 'a1 OK completed' forTag: 'a1').
	self deny: (client isTaggedLine: 'a2 OK completed' forTag: 'a1')! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:02'!
testIsUntaggedLine
	self assert: (client isUntaggedLine: '* 1 EXISTS').
	self deny: (client isUntaggedLine: 'a1 OK').
	self deny: (client isUntaggedLine: '')! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:01'!
testLiteralSizeFromLineAnswersByteCount
	self assert: (client literalSizeFromLine: '* 1 FETCH (BODY[] {12}') equals: 12.
	self assert: (client literalSizeFromLine: '{42}') equals: 42! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:01'!
testLiteralSizeFromLineAnswersNilWhenNoLiteral
	self assert: (client literalSizeFromLine: 'a1 OK') isNil.
	self assert: (client literalSizeFromLine: 'abc}') isNil! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:06'!
testMailboxNameFromListLine
	self assert: (client mailboxNameFromListLine: '* LIST () "/" "INBOX"') equals: 'INBOX'! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 17:14:21'!
testMessageCountFromStatusLine
	self assert: 3 equals: (client messageCountFromStatusLine: '* STATUS INBOX (MESSAGES 3)')! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 17:14:21'!
testMessageCountFromStatusLineEmpty
	self assert: 0 equals: (client messageCountFromStatusLine: '* STATUS INBOX (MESSAGES 0)')! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 17:14:22'!
testMessageCountFromStatusLineRejectsNonStatusLine
	self assert: nil equals: (client messageCountFromStatusLine: '* LIST () "/" INBOX')! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 17:14:22'!
testMessageCountFromStatusLineWithQuotedMailbox
	self assert: 5 equals: (client messageCountFromStatusLine: '* STATUS "Sent Items" (MESSAGES 5)')! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:21:07'!
testNextTagSequences
	self assert: client nextTag equals: 'a1'.
	self assert: client nextTag equals: 'a2'.
	self assert: client nextTag equals: 'a3'! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 17:15:12'!
testNumberOfMessagesInEmptyMailbox
	| stream |
	stream := ImapMockStream new.
	client instVarNamed: 'stream' put: stream.
	stream addLines: #('* STATUS INBOX (MESSAGES 0)' 'a1 OK STATUS completed').
	self assert: 0 equals: (client numberOfMessagesIn: 'INBOX').
	self assert: 'a1 STATUS "INBOX" (MESSAGES)' , String crlfString equals: stream sentLines! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 17:15:13'!
testNumberOfMessagesInNonEmptyMailbox
	| stream |
	stream := ImapMockStream new.
	client instVarNamed: 'stream' put: stream.
	stream addLines: #('* STATUS INBOX (MESSAGES 3)' 'a1 OK STATUS completed').
	self assert: 3 equals: (client numberOfMessagesIn: 'INBOX').
	self assert: 'a1 STATUS "INBOX" (MESSAGES)' , String crlfString equals: stream sentLines! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:20:56'!
testQuoteArgEscapesBackslashesAndDoubleQuotes
	"A quoted string wraps its argument in double quotes, escaping backslashes and double quotes."
	self assert: (client quoteArg: 'abc') equals: '"abc"'.
	self assert: (client quoteArg: 'a"b') equals: '"a\"b"'.
	self assert: (client quoteArg: 'a\b') equals: '"a\\b"'! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:20:57'!
testTokensInHonorsDoubleQuotedSubstrings
	self assert: (client tokensIn: 'a "b c" d') equals: #('a' '"b c"' 'd') asOrderedCollection.
	self assert: (client tokensIn: '"quoted"') equals: #('"quoted"') asOrderedCollection! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:20:57'!
testTokensInSplitsOnSeparators
	self assert: (client tokensIn: '* LIST () "/" INBOX') equals: #('*' 'LIST' '()' '"/"' 'INBOX') asOrderedCollection! !

!ImapClientTest methodsFor: 'tests' stamp: 'rc 1/Aug/2026 12:20:56'!
testUnquoteRemovesSurroundingDoubleQuotes
	self assert: (client unquote: '"INBOX"') equals: 'INBOX'.
	self assert: (client unquote: 'INBOX') equals: 'INBOX'! !

!ImapMessageTest methodsFor: 'helpers' stamp: 'rc 5/Aug/2026 18:28:08'!
utf8String: aByteArray
	^ UnicodeString fromUtf8Bytes: aByteArray! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:41:49'!
testBoundaryWithFollowingParameters
	| raw message bnd |
	bnd := 'XyZ987'.
	raw := 'Content-Type: multipart/signed; boundary="', bnd, '"; micalg="pgp-sha256"; protocol="application/pgp-signature"', String crlfString,
		String crlfString,
		'--', bnd, String crlfString,
		'Content-Type: text/plain; charset=utf-8', String crlfString, String crlfString,
		'Vier Worte hier', String crlfString,
		'--', bnd, String crlfString,
		'Content-Type: application/pgp-signature; name="signature.asc"', String crlfString, String crlfString,
		'-----BEGIN PGP SIGNATURE-----', String crlfString, '-----END PGP SIGNATURE-----', String crlfString,
		'--', bnd, '--'.
	message := ImapMessage fromRfc822: raw.
	self assert: 'Vier Worte hier' equals: message body.
	self assert: 1 equals: message attachments size.
	self assert: 'signature.asc' equals: (message attachments first) fileName! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:28:37'!
testDecodesBase64Body
	| raw message |
	raw := 'Content-Type: text/plain; charset=utf-8', String crlfString,
		'Content-Transfer-Encoding: base64', String crlfString,
		String crlfString,
		'SGFsbG8gV2VsdA=='.
	message := ImapMessage fromRfc822: raw.
	self assert: 'Hallo Welt' equals: message body! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:28:34'!
testDecodesBase64Subject
	| raw message |
	raw := 'Subject: =?UTF-8?B?R3LDtsOfZSBCZXRyZWZm?=', String crlfString,
		String crlfString,
		'Inhalt'.
	message := ImapMessage fromRfc822: raw.
	self assert: (self utf8String: #[71 114 195 182 195 159 101 32 66 101 116 114 101 102 102]) equals: message subject! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:28:41'!
testDecodesQuotedPrintableBody
	| raw message |
	raw := 'Content-Type: text/plain; charset=utf-8', String crlfString,
		'Content-Transfer-Encoding: quoted-printable', String crlfString,
		String crlfString,
		'Gr=C3=BC=C3=9Fe aus dem Test'.
	message := ImapMessage fromRfc822: raw.
	self assert: (self utf8String: #[71 114 195 188 195 159 101 32 97 117 115 32 100 101 109 32 84 101 115 116]) equals: message body! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:28:29'!
testDecodesQuotedPrintableSubject
	| raw message |
	raw := 'Subject: =?UTF-8?Q?Hallo_Welt=2C_Fr=C3=BChling?=', String crlfString,
		String crlfString,
		'Inhalt'.
	message := ImapMessage fromRfc822: raw.
	self assert: (self utf8String: #[72 97 108 108 111 32 87 101 108 116 44 32 70 114 195 188 104 108 105 110 103]) equals: message subject! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:28:46'!
testMultipartBodyAndAttachment
	| raw message attachment bnd |
	bnd := 'abc123'.
	raw := 'Content-Type: multipart/mixed; boundary="', bnd, '"', String crlfString,
		String crlfString,
		'--', bnd, String crlfString,
		'Content-Type: text/plain; charset=utf-8', String crlfString,
		String crlfString,
		'Hallo Body', String crlfString,
		'--', bnd, String crlfString,
		'Content-Type: application/octet-stream; name="daten.bin"', String crlfString,
		'Content-Disposition: attachment; filename="daten.bin"', String crlfString,
		'Content-Transfer-Encoding: base64', String crlfString,
		String crlfString,
		'AAECAw==', String crlfString,
		'--', bnd, '--'.
	message := ImapMessage fromRfc822: raw.
	self assert: 'Hallo Body' equals: message body.
	self assert: 1 equals: message attachments size.
	attachment := message attachments first.
	self assert: 'daten.bin' equals: attachment fileName.
	self assert: (attachment contentType beginsWith: 'application/octet-stream').
	self assert: (ByteArray with: 0 with: 1 with: 2 with: 3) equals: attachment content! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:28:55'!
testMultipleAttachments
	| raw message bnd |
	bnd := 'xyz'.
	raw := 'Content-Type: multipart/mixed; boundary="', bnd, '"', String crlfString,
		String crlfString,
		'--', bnd, String crlfString,
		'Content-Type: text/plain', String crlfString, String crlfString,
		'Text', String crlfString,
		'--', bnd, String crlfString,
		'Content-Type: application/octet-stream', String crlfString,
		'Content-Transfer-Encoding: base64', String crlfString, String crlfString,
		'QUJD', String crlfString,
		'--', bnd, String crlfString,
		'Content-Type: application/octet-stream', String crlfString,
		'Content-Transfer-Encoding: base64', String crlfString, String crlfString,
		'REVG', String crlfString,
		'--', bnd, '--'.
	message := ImapMessage fromRfc822: raw.
	self assert: 2 equals: message attachments size.
	self assert: (ByteArray with: 65 with: 66 with: 67) equals: (message attachments first) content.
	self assert: (ByteArray with: 68 with: 69 with: 70) equals: (message attachments second) content! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:28:50'!
testNonTextPartIsAttachmentWithoutDisposition
	| raw message |
	raw := 'Content-Type: multipart/mixed; boundary="bnd"', String crlfString,
		String crlfString,
		'--bnd', String crlfString,
		'Content-Type: application/pdf; name="brief.pdf"', String crlfString,
		String crlfString,
		'PDFDATA', String crlfString,
		'--bnd--'.
	message := ImapMessage fromRfc822: raw.
	self assert: 1 equals: message attachments size.
	self assert: 'brief.pdf' equals: (message attachments first) fileName.
	self assert: 'PDFDATA' equals: (message attachments first) content! !

!ImapMessageTest methodsFor: 'tests' stamp: 'rc 5/Aug/2026 18:28:12'!
testPlainTextMessage
	| raw message |
	raw := 'From: max@example.com', String crlfString,
		'To: mia@example.com', String crlfString,
		'Subject: Hallo', String crlfString,
		'Date: Wed, 05 Aug 2026 10:00:00 +0200', String crlfString,
		'Content-Type: text/plain; charset=utf-8', String crlfString,
		String crlfString,
		'Hallo Welt'.
	message := ImapMessage fromRfc822: raw.
	self assert: 'Hallo' equals: message subject.
	self assert: 'max@example.com' equals: message from.
	self assert: 'mia@example.com' equals: message to.
	self assert: 'Hallo Welt' equals: message body.
	self assert: message attachments isEmpty! !