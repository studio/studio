accessing
startLine
	| pt line chunk |
	pt := [ self startPrototype ] on: RJITFlashbackDataMissing do: [ ^ '?' ].
	chunk := [ pt sourceName ] on: RJITFlashbackDataMissing do: [ ^ '?' ].
	line := [ pt programCounterLine: self start ] on: RJITFlashbackDataMissing do: [ ^ chunk ].
	^ chunk , ':' , line asString.
