/**
 * @name CWE CATEGORY: 7PK - Security Features
 * @description nan
 * @kind problem
 * @problem.severity recommendation
 * @security-severity 9.3
 * @sub-severity high
 * @precision medium
 * @id py/core-cwe-254
 */

import python
import semmle.python.Concepts

from Function func, int numParams, int i
where
  numParams = func.getNumParameters() and
  (
    i = 0 and not func.hasStarArgs() and not func.hasKwArgs()
    or
    i = 1 and numParams > 1 and not func.hasStarArgs() and not func.hasKwArgs()
    or
    i = numParams - 1 and not func.hasStarArgs() and not func.hasKwArgs()
    or
    i = 0 and func.hasStarArgs() and not func.hasKwArgs()
    or
    i = numParams - 1 and func.hasStarArgs() and not func.hasKwArgs()
    or
    i = 0 and func.hasKwArgs()
    or
    i = 1 and func.hasKwArgs()
  )
select func,
  "Function '" + func.getName() + "' has $@ parameter(s).", i, "a"