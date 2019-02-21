"
I represent a list of profiles of related subject objects. The subjects could be a set of RaptorJIT processes; a set of VMProfile datasets within a process; a set of traces within a VMProfile dataset; etc.

I make it easy to compare and inspect the profiles.

"
Class {
	#name : #RJITProfileList,
	#superclass : #OrderedCollection,
	#instVars : [
		'vmprofiles'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #inspector }
RJITProfileList >> gtProcessesFor: aView [
	<gtView>
	| aList |
	
	aList := aView columnedList 
		title: 'Processes' translated;
		priority: 10;
		items: [ self collect: #subject ].

	aList column 
		title: 'Process' translated;
		matchParent;
		item: [ :item :index | (self at: index) subject ].
		
	aList column
		title: 'Samples' translated;
		matchParent;
		item: [ :item :index | (self at: index) all ].

	aList column
		title: 'Native Code' translated;
		matchParent;
		item: [ :item :index | ((self at: index) nativeCode printShowingDecimalPlaces: 1), '%'].
		
	aList column
		title: 'Virtual Machine' translated;
		matchParent;
		item: [ :item :index | ((self at: index) virtualMachine printShowingDecimalPlaces: 1), '%' ].
	
	aList column
		title: 'Garbage Collection' translated;
		matchParent;
		item: [ :item :index | ((self at: index) garbageCollection printShowingDecimalPlaces: 1), '%' ].

	^ aList
	
]

{ #category : #inspector }
RJITProfileList >> gtProfilesFor: aView [
	<gtView>
	| aList |
	
	aList := aView columnedList 
		title: 'Profiles' translated;
		priority: 10;
		items: [ self ].

	aList column 
		title: 'Subject' translated;
		matchParent;
		item: [ :item :index | item subject ].
		
	aList column
		title: 'Samples' translated;
		matchParent;
		item: [ :item :index | item all ].

	aList column
		title: 'Native Code' translated;
		matchParent;
		item: [ :item :index | (item nativeCode printShowingDecimalPlaces: 1), '%'].
		
	aList column
		title: 'Virtual Machine' translated;
		matchParent;
		item: [ :item :index | (item virtualMachine printShowingDecimalPlaces: 1), '%' ].
	
	aList column
		title: 'Garbage Collection' translated;
		matchParent;
		item: [ :item :index | (item garbageCollection printShowingDecimalPlaces: 1), '%' ].

	^ aList
	
]

{ #category : #inspector }
RJITProfileList >> gtSubjectsFor: aView [
	<gtView>
	| aList |
	
	aList := aView columnedList 
		title: 'Profiles' translated;
		priority: 10;
		items: [ self collect: #subject ].

	aList column 
		title: 'Subject' translated;
		matchParent;
		item: [ :item :index | (self at: index) subject ].
		
	aList column
		title: 'Samples' translated;
		matchParent;
		item: [ :item :index | (self at: index) all ].

	aList column
		title: 'Native Code' translated;
		matchParent;
		item: [ :item :index | ((self at: index) nativeCode printShowingDecimalPlaces: 1), '%'].
		
	aList column
		title: 'Virtual Machine' translated;
		matchParent;
		item: [ :item :index | ((self at: index) virtualMachine printShowingDecimalPlaces: 1), '%' ].
	
	aList column
		title: 'Garbage Collection' translated;
		matchParent;
		item: [ :item :index | ((self at: index) garbageCollection printShowingDecimalPlaces: 1), '%' ].

	^ aList
	
]

{ #category : #inspector }
RJITProfileList >> subjectViewTitled: aTitle subjectName: aName onView: aView [ 
	| aList |
	
	aList := aView columnedList 
		title: aTitle translated;
		priority: 10;
		items: [ self collect: #subject ].

	aList column 
		title: aName translated;
		matchParent;
		item: [ :item :index | (self at: index) subject ].
		
	aList column
		title: 'Samples' translated;
		width: 70;
		item: [ :item :index | (self at: index) all ].

	aList column
		title: 'Native' translated;
		width: 60;
		item: [ :item :index | ((self at: index) nativeCode rounded printString), '%'].
		
	aList column
		title: 'VM' translated;
		width: 60;
		item: [ :item :index | ((self at: index) virtualMachine rounded printString), '%' ].
	
	aList column
		title: 'GC' translated;
		width: 60;
		item: [ :item :index | ((self at: index) garbageCollection rounded printString), '%' ].

	^ aList
	
]
