instance creation
from: dict flashback: aFlashback
   flashback := aFlashback.
   gctrace := dict at: 'GCtrace'.
	jitState := flashback decodeJITStateAt: (dict at: 'jit_State').
