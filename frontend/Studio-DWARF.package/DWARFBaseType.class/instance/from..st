initialization
from: aCollection
   name := aCollection at: 'name'. 
	byteSize := aCollection at: 'byte_size'.
	encoding := aCollection at: 'encoding'.
	accessingSelector := self accessingSelectorForEncoding: encoding byteSize: byteSize.
