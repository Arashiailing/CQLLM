/**
 * @name Explicit invocation of `__del__` method
 * @description In Python, the `__del__` special method is automatically invoked by the interpreter
 *              during object destruction. Directly calling this method can lead to unpredictable
 *              behavior and is considered an anti-pattern. This query identifies explicit calls
 *              to `__del__` methods, excluding legitimate calls through `super()`.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python  // Import Python library for code analysis

// Define a class to detect explicit calls to the __del__ method
class ExplicitDelMethodCall extends Call {
  // Constructor: identifies calls where the method name is "__del__"
  ExplicitDelMethodCall() { 
    this.getFunc().(Attribute).getName() = "__del__" 
  }

  // Predicate to determine if this is a legitimate call to super().__del__()
  predicate isSuperInvocation() {
    // Check if the call occurs within a __del__ method definition
    exists(Function targetFunction | 
      targetFunction = this.getScope() and 
      targetFunction.getName() = "__del__" 
    |
      // Case 1: Direct call to self.__del__()
      // Verify that the first argument of the target function matches the first argument of the call
      targetFunction.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // Case 2: Call through super().__del__() or super(ClassName, self).__del__()
      exists(Call superCall | 
        superCall = this.getFunc().(Attribute).getObject() |
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// Select all explicit __del__ method calls that are not legitimate super() invocations
from ExplicitDelMethodCall explicitDelMethodCall
where not explicitDelMethodCall.isSuperInvocation()
select explicitDelMethodCall, "The __del__ special method is called explicitly."