"Studio loader.

 (Why not use Metacello? Doesn't seem to work well in a sandbox
 without network access.)"

| repo window |

repo := MCFileTreeRepository new directory: '@frontendSrc@' asFileReference.
repo allFileNames do: [ :file |
    Transcript show: 'Loading: ', file; cr.
    (repo versionFromFileNamed: file) load.
  ].

World closeAllWindowsDiscardingChanges.

window := GTInspector openOn: #WelcomeToStudio.
window
"
  removeBoxes;
  beSticky;
  beUnresizeable;
  beWithoutGrips;
"
  bounds: window world clearArea.

Smalltalk saveAs: 'new'.

