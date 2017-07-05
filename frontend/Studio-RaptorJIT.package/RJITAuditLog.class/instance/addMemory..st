initializing
addMemory: dict
   flashback := RJITFlashback new
		auditLog: self;
      previous: flashback;
      address: (dict at: 'address');
      data: (dict at: 'data') asByteArray;
      hint: (dict at: 'hint');
		yourself.
