/**
 * @name Non-callable called
 * @description Identifies calls to non-callable objects that will raise TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable
 */

import python
import Exceptions.NotImplemented

from 
  Call call, 
  Value invokedValue, 
  ClassValue valueClass, 
  Expr funcExpr, 
  AstNode origin
where
  // Extract function expression from call site
  funcExpr = call.getFunc() and
  
  // Resolve function expression to its concrete value and origin
  funcExpr.pointsTo(invokedValue, origin) and
  
  // Determine the class type of the invoked value
  valueClass = invokedValue.getClass() and
  
  // Verify the class is non-callable and type inference succeeded
  not valueClass.isCallable() and
  not valueClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ protocol
  not valueClass.hasAttribute("__get__") and
  
  // Exclude explicit None values
  not invokedValue = Value::named("None") and
  
  // Exclude NotImplemented in raise statements
  not use_of_not_implemented_in_raise(_, funcExpr)
select 
  call, 
  "Call to a $@ of $@.", 
  origin, 
  "non-callable", 
  valueClass, 
  valueClass.toString()