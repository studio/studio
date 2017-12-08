accessing
gtInspectorBytecodesIn: composite
	<gtInspectorPresentationOrder: 5>
	self jitState ifNil: [ ^nil ].
	self jitState gtInspectorBytecodesIn: composite.
