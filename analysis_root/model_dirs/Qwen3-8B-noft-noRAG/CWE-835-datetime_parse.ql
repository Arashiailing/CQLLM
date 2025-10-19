import python

/** @predicate Detects potential infinite loops in Python */
from WhileStmt w
where not exists (w.exitPoints())
select w, "Potential infinite loop: while loop without exit points"