/**
 * @name Non-callable invocation
 * @description Identifies code attempting to invoke non-callable objects,
 *              which would cause runtime TypeError exceptions during execution.
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
  Expr targetExpression, 
  AstNode originNode
where
  // Extract the expression being invoked at the call site
  targetExpression = invocationPoint.getFunc() and
  
  // Resolve the target expression to its concrete value and origin
  targetExpression.pointsTo(targetValue, originNode) and
  
  // Determine the class type of the invoked value
  targetClass = targetValue.getClass() and
  
  // Verify the class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference succeeded for accurate analysis
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ method that might be callable
  // through the descriptor protocol despite the class not being callable
  not targetClass.hasAttribute("__get__") and
  
  // Filter out None values which are explicitly non-callable
  not targetValue = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, targetExpression)
select 
  invocationPoint, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  targetClass, 
  targetClass.toString()