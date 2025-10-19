/**
 * @name Explicit invocation of `__del__` method
 * @description The `__del__` special method is automatically invoked by the Python interpreter during object finalization. 
 *              Explicitly calling this method can lead to unexpected behavior and should be avoided.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python

// Represents explicit calls to the __del__ special method
class ExplicitDeletionCall extends Call {
  // Constructor: Identifies calls where the invoked function is named __del__
  ExplicitDeletionCall() { 
    this.getFunc().(Attribute).getName() = "__del__" 
  }

  // Determines if the call is a valid super().__del__() invocation
  predicate isValidSuperCall() {
    // Verify the call occurs within a __del__ method context
    exists(Function enclosingDelMethod | 
      enclosingDelMethod = this.getScope() and 
      enclosingDelMethod.getName() = "__del__" 
    |
      // Case 1: Call uses the current object's 'self' parameter
      enclosingDelMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Call uses super() form (super().__del__() or super(Type, self).__del__())
      exists(Call superInvocation | 
        superInvocation = this.getFunc().(Attribute).getObject() |
        superInvocation.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// Identify all explicit __del__ calls that are not valid super() invocations
from ExplicitDeletionCall explicitCall
where not explicitCall.isValidSuperCall()
select explicitCall, "The __del__ special method is called explicitly."