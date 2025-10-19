/**
 * @name Explicit call to `__del__` method
 * @description Explicitly calling `__del__` is discouraged as it's meant for garbage collection.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python

// Represents explicit calls to the `__del__` special method
class ExplicitDelCall extends Call {
  ExplicitDelCall() { 
    // Identify calls where the invoked method is named "__del__"
    this.getFunc().(Attribute).getName() = "__del__" 
  }

  // Determines if this is a valid super() call within a destructor
  predicate isValidSuperCall() {
    exists(Function currentDestructor | 
      currentDestructor = this.getScope() and 
      currentDestructor.getName() = "__del__" 
    |
      // Case 1: Direct self-reference in destructor
      currentDestructor.getArg(0).asName().getVariable() = 
        this.getArg(0).(Name).getVariable()
      or
      // Case 2: super() invocation pattern
      exists(Call superInvocation | 
        superInvocation = this.getFunc().(Attribute).getObject() |
        superInvocation.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// Identify problematic explicit __del__ calls
from ExplicitDelCall problematicDelCall
where not problematicDelCall.isValidSuperCall()
select problematicDelCall, 
  "Explicit call to __del__ method - should only be invoked by garbage collector"