import python

from WhileStmt w
where w.condition is null or w.condition.isTrue()
select w, "Potential infinite loop leading to uncontrolled resource consumption"

from FunctionDecl f, CallExpr c
where c.calledMethod().name = f.name and c.isInBody(f)
select f, "Potential infinite recursion leading to uncontrolled resource consumption"

from CallExpr c
where c.calledMethod().name = "start" and c.getArgument(0).getType().isInstanceOf(Thread)
select c, "Potential uncontrolled thread creation"