/**
 * @name CWE-125: Out-of-bounds Read
 * @id py/setup
 */
import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.python.security.dataflow.ArrayIndexOutOfBounds

from ArrayIndexOutOfBoundsProblem problem
where problem.isOutOfBounds()
select problem, "Potential out-of-bounds read detected."