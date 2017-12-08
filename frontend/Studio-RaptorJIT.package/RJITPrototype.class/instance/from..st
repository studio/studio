instance creation
from: aGCproto
	gcproto := aGCproto.
	firstline := (aGCproto child: #firstline) value.
	sourceName := gcproto flashback decodeLuaStringAt: (gcproto child: #chunkname).