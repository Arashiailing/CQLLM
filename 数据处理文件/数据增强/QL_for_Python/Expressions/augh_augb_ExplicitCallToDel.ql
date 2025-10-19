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
    // Identify calls to __del__ method via attribute access
    exists(Attribute delAttr | 
      delAttr = this.getFunc() and 
      delAttr.getName() = "__del__"
    ) and
    // Exclude super invocations and self-calls within __del__ methods
    not (
      exists(Function containingMethod | 
        containingMethod = this.getScope() and 
        containingMethod.getName() = "__del__" |
        // Case 1: Direct self invocation (e.g., self.__del__())
        containingMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
        or
        // Case 2: Super invocation (e.g., super().__del__() or super(Class, self).__del__())
        exists(Call superCall | 
          superCall = this.getFunc().(Attribute).getObject() and
          superCall.getFunc().(Name).getId() = "super"
        )
      )
    )
  }
}

from ExplicitDelCall delCall
select delCall, "The __del__ special method is called explicitly."