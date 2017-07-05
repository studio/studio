instance creation
print: value on: aStream
   aStream nextPutAll: '<', self typename, '>'
