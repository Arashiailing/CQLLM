/**
 * @name Invocation of Non-Callable Objects
 * @description Detects function call expressions where the target object
 *              cannot be invoked, which would cause TypeError at runtime.
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
  Call funcCall, 
  Value calleeValue, 
  ClassValue calleeClass, 
  Expr targetExpr, 
  AstNode originNode
where
  // Extract the target expression from the function call
  targetExpr = funcCall.getFunc() and
  
  // Resolve the target expression to its value and origin
  targetExpr.pointsTo(calleeValue, originNode) and
  
  // Get the class of the callee value
  calleeClass = calleeValue.getClass() and
  
  // Check if the callee's class is not callable
  not calleeClass.isCallable() and
  
  // Ensure type inference was successful
  not calleeClass.failedInference(_) and
  
  // Exclude descriptor objects that might be callable through the descriptor protocol
  not calleeClass.hasAttribute("__get__") and
  
  // Exclude None values which are explicitly non-callable
  not calleeValue = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, targetExpr)
select 
  funcCall, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  calleeClass, 
  calleeClass.toString()