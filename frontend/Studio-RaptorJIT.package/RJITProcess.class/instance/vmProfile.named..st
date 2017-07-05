accessing
vmProfile: aVMProfile named: name 
	vmprofiles ifNil: [ vmprofiles := Dictionary new. ].
	vmprofiles at: name put: aVMProfile.
