Class {
	#name : #DWARFMember,
	#superclass : #Object,
	#instVars : [
		'name',
		'type',
		'location'
	],
	#category : #'Studio-DWARF'
}

{ #category : #accessing }
DWARFMember >> byteSize [
	^ type byteSize.
]

{ #category : #decoding }
DWARFMember >> decode: byteArray address: baseAddress flashback: flashback [
   | address |
   address := baseAddress + location.
   	^ type decode: (byteArray copyFrom: location + 1 to: location + type byteSize)
	   address: address flashback: flashback.
]

{ #category : #initializing }
DWARFMember >> from: dict via: references [
   name := dict at: 'name' ifAbsent: [nil].
	type := references at: (dict at: 'type').
	location := dict at: 'data_member_location' ifAbsent: [0].

]

{ #category : #accessing }
DWARFMember >> location [
	^location
]

{ #category : #accessing }
DWARFMember >> name [
	^name
]

{ #category : #accessing }
DWARFMember >> type [
	^type
]
