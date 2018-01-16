accessing
asOrderedCollection
	| c o |
	c := OrderedCollection new.
	o := self.
	[ o ] whileNotNil: [ c add: o. o := o previous. ].
	^ c.