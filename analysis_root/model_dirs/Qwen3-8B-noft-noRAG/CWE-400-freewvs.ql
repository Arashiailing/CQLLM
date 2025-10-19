import python

/**
 * Detect potential infinite loops with constant 'True' conditions.
 */
from WhileLoopStmt w
where w.getCondition().isLiteral("True")
select w, "Potential infinite loop: while loop condition is always 'True'"

/**
 * Detect for loops with potentially unbounded iterations.
 */
from ForLoopStmt f
where exists(f.getIterators()) and f.getIterators().getEnd() instanceof RangeExpr
  and f.getIterators().getEnd().getStart().isLiteral()
  and (f.getIterators().getEnd().getStart().getValue().asInt() > 100000 or 
       f.getIterators().getEnd().getStart().getValue().asInt() == -1)
select f, "Potential unbounded iteration: for loop with large or negative range end value"

/**
 * Detect recursive functions without explicit termination conditions.
 */
from FunctionDecl fd
where fd.hasRecursiveCall()
  and not (fd.getParameters().isEmpty() and fd.getBody().isEmpty())
select fd, "Potential infinite recursion: function may lack proper termination conditions"