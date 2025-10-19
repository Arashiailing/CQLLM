/**
 * @name Non-callable invoked
 * @description Detects invocations of objects that lack callable semantics,
 *              which will cause TypeError exceptions at runtime.
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
  Call invocation, 
  Value invokedValue, 
  ClassValue valueClass, 
  Expr invocationExpr, 
  AstNode originLocation
where
  // Extract the function expression being called
  invocationExpr = invocation.getFunc() and
  
  // Resolve the expression to its target value and origin
  invocationExpr.pointsTo(invokedValue, originLocation) and
  
  // Determine the class of the invoked object
  valueClass = invokedValue.getClass() and
  
  // Verify the object's class lacks callable behavior
  not valueClass.isCallable() and
  
  // Ensure type inference succeeded for accurate results
  not valueClass.failedInference(_) and
  
  // Exclude descriptor protocol objects with __get__ method
  not valueClass.hasAttribute("__get__") and
  
  // Filter out explicit None values (always non-callable)
  not invokedValue = Value::named("None") and
  
  // Special case: exclude NotImplemented in raise contexts
  not use_of_not_implemented_in_raise(_, invocationExpr)
select 
  invocation, 
  "Call to a $@ of $@.", 
  originLocation, 
  "non-callable", 
  valueClass, 
  valueClass.toString()