/**
 * @name Explicit `__del__` method invocation
 * @description Detects explicit calls to the `__del__` special method, which should only be
 *              invoked by the Python virtual machine during object finalization.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python

/**
 * Represents an explicit call to the `__del__` special method.
 * This class identifies direct invocations of `__del__` that may indicate
 * incorrect usage of Python's finalization mechanism.
 */
class ExplicitDeletionInvocation extends Call {
  ExplicitDeletionInvocation() { 
    // Check if the called method is "__del__"
    this.getFunc().(Attribute).getName() = "__del__" 
  }

  /**
   * Determines if this call is a valid super() invocation within a `__del__` method.
   * Valid cases include:
   * 1. Calling self.__del__() from within a __del__ method
   * 2. Calling super().__del__() or super(Type, self).__del__() from within a __del__ method
   */
  predicate isValidSuperCall() {
    exists(Function parentMethod | 
      // The call must be inside a __del__ method
      parentMethod = this.getScope() and 
      parentMethod.getName() = "__del__" 
    |
      // Case 1: Using self parameter of the current __del__ method
      parentMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Using super() to call parent class __del__
      exists(Call superInvocation | 
        superInvocation = this.getFunc().(Attribute).getObject() |
        superInvocation.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// Find all explicit __del__ calls that are not valid super() invocations
from ExplicitDeletionInvocation deletionInvocation
where not deletionInvocation.isValidSuperCall()
select deletionInvocation, "The __del__ special method is called explicitly."