initializating
from: dict flashback: aFlashback
   flashback := aFlashback.
   jitState := flashback decodeJITStateAt: (dict at: 'jit_State').
