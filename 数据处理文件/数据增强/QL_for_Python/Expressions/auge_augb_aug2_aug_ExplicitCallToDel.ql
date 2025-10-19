/**
 * @name Explicit `__del__` method invocation
 * @description Detects direct calls to the `__del__` special method, which should only be
 *              invoked by the Python runtime during object finalization.
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
 * Represents direct invocations of the `__del__` special method.
 * This class identifies calls to `__del__` that bypass Python's automatic
 * finalization mechanism, potentially causing unexpected behavior.
 */
class ExplicitDelCall extends Call {
  ExplicitDelCall() { 
    // Identify calls where the invoked method is named "__del__"
    exists(Attribute methodAttr | 
      methodAttr = this.getFunc() and 
      methodAttr.getName() = "__del__" 
    )
  }

  /**
   * Determines if this call represents a valid super() invocation within a `__del__` method.
   * Valid cases include:
   * 1. Calling self.__del__() from within a __del__ method
   * 2. Calling super().__del__() or super(Type, self).__del__() from within a __del__ method
   */
  predicate isValidSuperCall() {
    // Verify the call occurs within a __del__ method
    exists(Function enclosingMethod | 
      enclosingMethod = this.getScope() and 
      enclosingMethod.getName() = "__del__" 
    |
      // Case 1: Call uses the self parameter of the current __del__ method
      enclosingMethod.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Call uses super() to invoke parent class __del__
      exists(Call superCall | 
        superCall = this.getFunc().(Attribute).getObject() and
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// Identify all explicit __del__ calls that are not valid super() invocations
from ExplicitDelCall explicitDelCall
where not explicitDelCall.isValidSuperCall()
select explicitDelCall, "The __del__ special method is called explicitly."