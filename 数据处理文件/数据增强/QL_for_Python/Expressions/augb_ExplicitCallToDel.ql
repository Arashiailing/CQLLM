/**
 * @name Explicit invocation of `__del__` method
 * @description The special method `__del__` is intended to be invoked by the Python runtime during garbage collection. Explicitly calling this method can lead to unexpected behavior and should be avoided.
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
    // Verify the target is an attribute access with name "__del__"
    exists(Attribute attr | attr = this.getFunc() and attr.getName() = "__del__")
  }

  predicate isSuperInvocation() {
    // Check if call occurs within a __del__ method
    exists(Function delMethod | 
      delMethod = this.getScope() and 
      delMethod.getName() = "__del__" |
      // Case 1: Direct self invocation (e.g., self.__del__())
      delMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Super invocation (e.g., super().__del__() or super(Class, self).__del__())
      exists(Call superCall | 
        superCall = this.getFunc().(Attribute).getObject() and
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

from ExplicitDelCall explicitInvocation
where not explicitInvocation.isSuperInvocation()
select explicitInvocation, "The __del__ special method is called explicitly."