Extension { #name : #Integer }

{ #category : #'*studio-raptorjit' }
Integer >> asX64RegisterAssignment [
	^ #(
		rax rcx rdx rbx rsp rbp rsi rdi r8 r9 r10 r11 r12 r13 r14 r15
		xmm0 xmm1 xmm2 xmm3 xmm4 xmm5 xmm6 xmm7 xmm8
		xmm9 xmm10 xmm11 xmm12 xmm13 xmm14 mm15
		) at: self + 1.

]
