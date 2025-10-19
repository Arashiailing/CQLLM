/**
 * @name Non-callable called
 * @description Identifies calls to objects that are not callable, which will raise a TypeError at runtime.
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
  Call invocationSite, 
  Value invokedObject, 
  ClassValue objectType, 
  Expr invokedExpression, 
  AstNode valueOrigin
where
  // Extract the expression being invoked from the call site
  invokedExpression = invocationSite.getFunc() and
  
  // Resolve the invoked expression to its concrete value and origin
  invokedExpression.pointsTo(invokedObject, valueOrigin) and
  
  // Determine the class type of the invoked object
  objectType = invokedObject.getClass() and
  
  // Pre-filter common non-callable cases before type inference
  not invokedObject = Value::named("None") and
  not use_of_not_implemented_in_raise(_, invokedExpression) and
  
  // Verify type inference succeeded and the class is not callable
  not objectType.failedInference(_) and
  not objectType.isCallable() and
  
  // Exclude descriptor objects callable via protocol
  not objectType.hasAttribute("__get__")
select 
  invocationSite, 
  "Call to a $@ of $@.", 
  valueOrigin, 
  "non-callable", 
  objectType, 
  objectType.toString()