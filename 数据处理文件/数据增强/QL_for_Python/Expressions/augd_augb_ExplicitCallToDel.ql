/**
 * @name Explicit invocation of `__del__` method
 * @description Detects explicit calls to Python's special method `__del__`, which should only be invoked by the runtime during garbage collection. Explicit invocation may cause unexpected behavior.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python

class ExplicitDelMethodCall extends Call {
  ExplicitDelMethodCall() {
    // Identify calls targeting the __del__ method via attribute access
    exists(Attribute delAttr | 
      delAttr = this.getFunc() and 
      delAttr.getName() = "__del__"
    )
  }

  predicate isSuperInvocation() {
    // Determine if call occurs within a __del__ method context
    exists(Function containingDelMethod | 
      containingDelMethod = this.getScope() and 
      containingDelMethod.getName() = "__del__" |
      // Case 1: Direct self-reference invocation (e.g., self.__del__())
      containingDelMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Superclass invocation (e.g., super().__del__() or super(Class, self).__del__())
      exists(Call superInvocation | 
        superInvocation = this.getFunc().(Attribute).getObject() and
        superInvocation.getFunc().(Name).getId() = "super"
      )
    )
  }
}

from ExplicitDelMethodCall explicitDelCall
where not explicitDelCall.isSuperInvocation()
select explicitDelCall, "The __del__ special method is called explicitly."