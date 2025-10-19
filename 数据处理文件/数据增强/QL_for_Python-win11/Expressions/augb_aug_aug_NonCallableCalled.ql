/**
 * @name Non-callable invoked
 * @description Detects code that attempts to call objects which are not callable,
 *              leading to runtime TypeError exceptions during execution.
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
  Call callSite, 
  Value invokedValue, 
  ClassValue valueClass, 
  Expr calledExpression, 
  AstNode valueOrigin
where
  // Identify the expression being invoked in the call site
  calledExpression = callSite.getFunc() and
  
  // Trace the called expression to its resolved value and origin point
  calledExpression.pointsTo(invokedValue, valueOrigin) and
  
  // Determine the class of the value being invoked
  valueClass = invokedValue.getClass() and
  
  // Verify the value's class is not callable
  not valueClass.isCallable() and
  
  // Ensure type inference was successful for accurate analysis
  not valueClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ method which might be callable
  // through the descriptor protocol even if the class itself is not callable
  not valueClass.hasAttribute("__get__") and
  
  // Filter out None values which are explicitly non-callable
  not invokedValue = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, calledExpression)
select 
  callSite, 
  "Call to a $@ of $@.", 
  valueOrigin, 
  "non-callable", 
  valueClass, 
  valueClass.toString()