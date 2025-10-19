/**
 * @name Explicit invocation of `__del__` method
 * @description Detects explicit calls to the `__del__` special method, which should only be invoked by the Python garbage collector during object finalization.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python

// Defines a class representing explicit calls to the __del__ method
class ExplicitDelMethodCall extends Call {
  // Constructor that identifies calls to the __del__ method
  ExplicitDelMethodCall() { this.getFunc().(Attribute).getName() = "__del__" }

  // Predicate to determine if this is a valid super().__del__() call
  predicate isValidSuperCall() {
    // Check if the call occurs within a __del__ method definition
    exists(Function enclosingFunction | 
      enclosingFunction = this.getScope() and 
      enclosingFunction.getName() = "__del__" 
    |
      // Case 1: The caller uses the current object's self parameter
      enclosingFunction.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: The call is in the form super().__del__() or super(Type, self).__del__()
      exists(Call superCall | 
        superCall = this.getFunc().(Attribute).getObject() |
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// Select all invalid explicit calls to __del__ (non-super calls)
from ExplicitDelMethodCall delMethodInvocation
where not delMethodInvocation.isValidSuperCall()
select delMethodInvocation, "The __del__ special method is called explicitly."