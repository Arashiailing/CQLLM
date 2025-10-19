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
  Call invocationNode, 
  Value targetValue, 
  ClassValue targetClass, 
  Expr functionExpr, 
  AstNode valueSource
where
  // Extract the function expression from the call site
  functionExpr = invocationNode.getFunc() and
  
  // Resolve the function expression to its concrete value and origin
  functionExpr.pointsTo(targetValue, valueSource) and
  
  // Determine the class of the invoked value
  targetClass = targetValue.getClass() and
  
  // Verify the value's class is not callable
  not targetClass.isCallable() and
  
  // Ensure successful type inference for accurate analysis
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ method (callable via protocol)
  not targetClass.hasAttribute("__get__") and
  
  // Filter out explicit None values (known non-callable)
  not targetValue = Value::named("None") and
  
  // Special case: exclude NotImplemented in raise statements
  not use_of_not_implemented_in_raise(_, functionExpr)
select 
  invocationNode, 
  "Call to a $@ of $@.", 
  valueSource, 
  "non-callable", 
  targetClass, 
  targetClass.toString()