gt-inspector-extension
gtInspectorBytecodesIn: composite
	<gtInspectorPresentationOrder: 1>
	jitState ifNil: [ ^nil ].
	jitState gtInspectorBytecodesIn: composite.
