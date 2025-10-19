/**
 * @name Explicit invocation of `__del__` method
 * @description Directly calling Python's special method `__del__` is discouraged as it's designed for automatic garbage collection. Manual invocation may cause unpredictable behavior and resource management issues.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python

class ExplicitDelCall extends Call {
  ExplicitDelCall() {
    // Identify calls targeting the __del__ special method
    exists(Attribute delAttr | 
      delAttr = this.getFunc() and 
      delAttr.getName() = "__del__"
    )
  }

  predicate isSuperInvocation() {
    // Determine if call occurs within a __del__ method context
    exists(Function currentDelMethod | 
      currentDelMethod = this.getScope() and 
      currentDelMethod.getName() = "__del__" |
      // Case 1: Direct self-invocation pattern (e.g., self.__del__())
      currentDelMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Superclass invocation pattern (e.g., super().__del__())
      exists(Call superCallExpr | 
        superCallExpr = this.getFunc().(Attribute).getObject() and
        superCallExpr.getFunc().(Name).getId() = "super"
      )
    )
  }
}

from ExplicitDelCall explicitInvocation
where not explicitInvocation.isSuperInvocation()
select explicitInvocation, "The __del__ special method is called explicitly."