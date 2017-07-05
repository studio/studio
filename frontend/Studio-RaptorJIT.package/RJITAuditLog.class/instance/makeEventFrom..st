initialization
makeEventFrom: dict
   | event |
event := dict at: 'event'.
   event = 'trace_stop' ifTrue: [ ^RJITTraceStopEvent new from: dict flashback: flashback ].
   event = 'trace_abort' ifTrue: [ ^RJITTraceAbortEvent new from: dict flashback: flashback ].
   ^RJITUnknownEvent new from: dict flashback: flashback.
