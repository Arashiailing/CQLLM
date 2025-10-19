import python
import semmle.code.java.Expressions
import semmle.code.cpp.ControlFlow

from Function f, Call c
where
  f.hasName("unbounded_loop") or
  f.hasName("infinite_recursion") or
  (c.getMethod().getName() = "read" and c.getArgument(0).getType().getSimpleName() = "int" and c.getArgument(0).getValue().toString() = "infinity")
select f, "Potential uncontrolled resource consumption due to infinite loop or recursion"