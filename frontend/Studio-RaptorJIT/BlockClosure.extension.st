Extension { #name : #BlockClosure }

{ #category : #'*studio-raptorjit' }
BlockClosure >> gtInspectorActionCopyValueToClipboard [
	^ GLMGenericAction new 
		action: [ 
			Clipboard clipboardText: self value.
			UIManager default inform: 'Copied to clipboard'. ];
		icon: GLMUIThemeExtraIcons glamorousSave;
		title: 'Export to clipboard'.

]
