import python

// Detect infinite loops
from Loop l
where l.isInfinite()
select l, "Potential infinite loop leading to resource consumption."

// Detect recursive functions without depth limits
from Function f
where f.isRecursive() and f.getRecursionDepth() > 1000
select f, "Recursive function with high recursion depth."

// Detect file handles not being closed
from Call c
where c.getCallee().getName() = "open" and not exists (c.getReturn().getAssignedTo().getVariable().hasFinally())
select c, "File opened but not closed."

// Detect extractall calls on TarFile which may extract all files without limit
from Call c
where c.getCallee().getName() = "extractall" and c.getBase().getName() = "TarFile"
select c, "Potential uncontrolled resource consumption in TarFile.extractall."