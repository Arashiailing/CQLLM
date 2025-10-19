/**
 * @name Non-callable invoked
 * @description Identifies code that attempts to invoke objects which are not callable,
 *              potentially resulting in TypeError exceptions during execution.
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
  Call callNode, 
  Value targetObject, 
  ClassValue targetClass, 
  Expr calleeExpr, 
  AstNode sourceNode
where
  // Extract the callee expression from the call node
  calleeExpr = callNode.getFunc() and
  
  // Resolve the callee to its underlying value and trace its origin
  calleeExpr.pointsTo(targetObject, sourceNode) and
  
  // Obtain the class of the target object being invoked
  targetClass = targetObject.getClass() and
  
  // Core check: verify the object's class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference was successful for accurate analysis
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects implementing __get__ method
  // These objects can be callable through the descriptor protocol
  not targetClass.hasAttribute("__get__") and
  
  // Filter out None values as they are explicitly non-callable
  not targetObject = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpr)
select 
  callNode, 
  "Call to a $@ of $@.", 
  sourceNode, 
  "non-callable", 
  targetClass, 
  targetClass.toString()