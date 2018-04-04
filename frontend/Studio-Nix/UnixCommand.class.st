Class {
	#name : #UnixCommand,
	#superclass : #Object,
	#instVars : [
		'process',
		'output'
	],
	#category : #'Studio-Nix'
}

{ #category : #running }
UnixCommand >> gtInspectorOutputIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite text title: 'Output'; display: [ self poll ]; wantsAutomaticRefresh: true.
]

{ #category : #running }
UnixCommand >> poll [
	output := output , process upToEnd.
	^output
]

{ #category : #running }
UnixCommand >> run: command [
	output := ''.
	process := PipeableOSProcess command: command.
]
