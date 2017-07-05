accessing
printOn: aStream
   super printOn: aStream.
   aStream nextPutAll: ' on '.
   dwarfValue printOn: aStream.