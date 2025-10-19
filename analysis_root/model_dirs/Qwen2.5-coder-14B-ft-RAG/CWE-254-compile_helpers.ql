/**
 * @name CWE CATEGORY: 7PK - Security Features
 * @description nan
 * @kind problem
 * @id py/compile_helpers
 * @problem.severity recommendation
 */

import python
import semmle.python.ApiGraphs

from Expr e, string fun
where
  (
    e.(Call).getFunc().(Attribute).getName() = "compile" and
    fun = "compile"
  )
  or
  (
    e.(Call).getFunc().(Name).getId() = "__import__" and
    fun = "__import__"
  )
select e, "Using dangerous helper function '" + fun + "'."