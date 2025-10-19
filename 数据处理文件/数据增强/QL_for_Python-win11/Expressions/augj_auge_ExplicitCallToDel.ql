/**
 * @name Explicit call to `__del__` method
 * @description The `__del__` special method should not be called explicitly, as it's invoked by the Python garbage collector during object finalization.
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
class ExplicitDunderDelCall extends Call {
  // Constructor: Identifies all expressions that call the __del__ method
  ExplicitDunderDelCall() { this.getFunc().(Attribute).getName() = "__del__" }

  // Determines if this is a legitimate call to a parent class's __del__ method
  predicate isSuperCall() {
    // Check if the call occurs within a __del__ method
    exists(Function delMethod | delMethod = this.getScope() and delMethod.getName() = "__del__" |
      // Case 1: Calling __del__ on self within the __del__ method
      delMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Calling parent's __del__ via super()
      exists(Call superCall | 
        superCall = this.getFunc().(Attribute).getObject() and
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// Find all explicit calls to __del__ that are not legitimate parent class calls
from ExplicitDunderDelCall explicitDunderDelCall
where not explicitDunderDelCall.isSuperCall()
select explicitDunderDelCall, "The __del__ special method is called explicitly."