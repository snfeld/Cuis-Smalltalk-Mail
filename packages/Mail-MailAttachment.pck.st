'From Cuis7.8 [latest update: #7977] on 12 August 2026 at 11:32:46 am'!
'Description '!
!provides: 'Mail-MailAttachment' 1 1!
SystemOrganization addCategory: #'Mail-MailAttachment'!


!classDefinition: #MailAttachment category: #'Mail-MailAttachment'!
Object subclass: #MailAttachment
	instanceVariableNames: 'fileName contentType content'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Mail-MailAttachment'!
!classDefinition: 'MailAttachment class' category: #'Mail-MailAttachment'!
MailAttachment class
	instanceVariableNames: ''!


!MailAttachment methodsFor: 'accessing' stamp: 'H9 12/Aug/2026 11:29:45'!
content
	"Answer the attachment's content."
	^ content! !

!MailAttachment methodsFor: 'accessing' stamp: 'H9 12/Aug/2026 11:29:45'!
contentType
	"Answer the attachment's MIME content type."
	^ contentType! !

!MailAttachment methodsFor: 'accessing' stamp: 'H9 12/Aug/2026 11:29:45'!
fileName
	"Answer the attachment's file name."
	^ fileName! !

!MailAttachment methodsFor: 'initialize-release' stamp: 'H9 12/Aug/2026 11:29:45'!
initializeFileName: aFileName contentType: aContentType content: aContent
	fileName := aFileName.
	contentType := aContentType.
	content := aContent.! !

!MailAttachment class methodsFor: 'instance creation' stamp: 'H9 12/Aug/2026 11:29:45'!
fileName: aFileName contentType: aContentType content: aContent
	^ self new initializeFileName: aFileName contentType: aContentType content: aContent! !