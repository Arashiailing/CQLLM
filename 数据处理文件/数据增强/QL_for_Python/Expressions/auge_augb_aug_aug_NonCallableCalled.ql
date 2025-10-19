/**
 * @name Non-callable invoked
 * @description Identifies code that attempts to invoke objects which are not callable,
 *              potentially causing TypeError exceptions at runtime.
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
  Call invocationPoint, 
  Value targetValue, 
  ClassValue targetClass, 
  Expr calleeExpression, 
  AstNode valueSource
where
  // Extract the expression being invoked at the call site
  calleeExpression = invocationPoint.getFunc() and
  
  // Perform points-to analysis to determine the value and its origin
  calleeExpression.pointsTo(targetValue, valueSource) and
  
  // Identify the class of the value being invoked
  targetClass = targetValue.getClass() and
  
  // Verify that the class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference was successful for reliable results
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ method which may be callable
  // through the descriptor protocol despite the class not being callable
  not targetClass.hasAttribute("__get__") and
  
  // Filter out None values which are inherently non-callable
  not targetValue = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpression)
select 
  invocationPoint, 
  "Call to a $@ of $@.", 
  valueSource, 
  "non-callable", 
  targetClass, 
  targetClass.toString()