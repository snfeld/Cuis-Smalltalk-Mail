'From Cuis7.8 [latest update: #7977] on 12 August 2026 at 11:34:44 am'!
'Description '!
!provides: 'Tests-MailAttachment' 1 0!
!requires: 'Mail-MailAttachment' 1 nil 1!
SystemOrganization addCategory: #'Tests-MailAttachment'!


!classDefinition: #MailAttachmentTest category: #'Tests-MailAttachment'!
TestCase subclass: #MailAttachmentTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-MailAttachment'!
!classDefinition: 'MailAttachmentTest class' category: #'Tests-MailAttachment'!
MailAttachmentTest class
	instanceVariableNames: ''!


!MailAttachmentTest methodsFor: 'tests' stamp: 'H9 12/Aug/2026 11:33:23'!
testConstruction
	| attachment |
	attachment := MailAttachment fileName: 'report.pdf' contentType: 'application/pdf' content: 'data'.
	self assert: attachment fileName equals: 'report.pdf'.
	self assert: attachment contentType equals: 'application/pdf'.
	self assert: attachment content equals: 'data'.! !

!MailAttachmentTest methodsFor: 'tests' stamp: 'H9 12/Aug/2026 11:33:23'!
testImapAttachmentWithDisposition
	| attachment |
	attachment := ImapAttachment fileName: 'logo.png' contentType: 'image/png' content: 'bits' disposition: 'inline'.
	self assert: attachment fileName equals: 'logo.png'.
	self assert: attachment contentType equals: 'image/png'.
	self assert: attachment content equals: 'bits'.
	self assert: attachment disposition equals: 'inline'.
	self assert: attachment class superclass == MailAttachment.! !

!MailAttachmentTest methodsFor: 'tests' stamp: 'H9 12/Aug/2026 11:33:23'!
testIsKindOfMailAttachment
	self assert: (MailAttachment new isKindOf: MailAttachment).
	self assert: (ImapAttachment new isKindOf: MailAttachment).
	self assert: (SmtpAttachment new isKindOf: MailAttachment).! !

!MailAttachmentTest methodsFor: 'tests' stamp: 'H9 12/Aug/2026 11:33:23'!
testSmtpAttachmentInheritsAccessors
	| attachment |
	attachment := SmtpAttachment fileName: 'notes.txt' contentType: 'text/plain' content: 'hello'.
	self assert: attachment fileName equals: 'notes.txt'.
	self assert: attachment contentType equals: 'text/plain'.
	self assert: attachment content equals: 'hello'.
	self assert: attachment class superclass == MailAttachment.! !