/**
 * @name Explicit invocation of `__del__` method
 * @description Direct calls to the special method `__del__` are problematic, as this method should only be invoked by Python's garbage collector. Explicit invocation may cause unpredictable program behavior.
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
    // Ensure target is an attribute access with "__del__" name
    exists(Attribute targetAttr | 
      targetAttr = this.getFunc() and 
      targetAttr.getName() = "__del__"
    )
  }

  predicate isValidSuperInvocation() {
    // Check if call occurs within a __del__ implementation
    exists(Function containingMethod | 
      containingMethod = this.getScope() and 
      containingMethod.getName() = "__del__" |
      // Case 1: Direct self reference (self.__del__())
      containingMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Superclass invocation (super().__del__() or super(Class, self).__del__())
      exists(Call superCallExpr | 
        superCallExpr = this.getFunc().(Attribute).getObject() and
        superCallExpr.getFunc().(Name).getId() = "super"
      )
    )
  }
}

from ExplicitDelCall problematicCall
where not problematicCall.isValidSuperInvocation()
select problematicCall, "The __del__ special method is called explicitly."