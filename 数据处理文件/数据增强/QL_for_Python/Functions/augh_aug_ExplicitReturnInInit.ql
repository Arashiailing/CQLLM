/**
 * @name `__init__` method returns a value
 * @description In Python, the `__init__` method should only initialize an object instance
 *              and should not explicitly return any value (it implicitly returns None).
 *              Returning a non-None value from `__init__` will raise a TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

// Identify explicit return statements within __init__ methods
from Return explicitReturn, Expr returnedValue
where
  // Verify the return statement is inside an __init__ method
  exists(Function initFunc | 
    initFunc.isInitMethod() and 
    explicitReturn.getScope() = initFunc
  ) and
  // Extract the value being returned
  explicitReturn.getValue() = returnedValue and
  // Ensure the returned value is not None
  not returnedValue.pointsTo(Value::none_()) and
  // Exclude returns from functions that never return
  not exists(FunctionValue nonReturningFunc | 
    nonReturningFunc.getACall() = returnedValue.getAFlowNode() | 
    nonReturningFunc.neverReturns()
  ) and
  // Avoid duplicate reports for chained __init__ calls
  not exists(Attribute otherInitCall | 
    otherInitCall = returnedValue.(Call).getFunc() | 
    otherInitCall.getName() = "__init__"
  )
// Select problematic return statements with consistent message
select explicitReturn, "Explicit return in __init__ method."