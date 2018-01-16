accessing
gtInspectorBytecodesIn: composite
	<gtInspectorPresentationOrder: 1>
	self jitState ifNil: [ ^nil ].
	self jitState gtInspectorBytecodesIn: composite.
