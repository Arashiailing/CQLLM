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
  Call callNode, 
  Value calleeValue, 
  ClassValue targetClass, 
  Expr calleeExpr, 
  AstNode originNode
where
  // Extract the callee expression from the call site
  calleeExpr = callNode.getFunc() and
  
  // Resolve the callee expression to its concrete value and origin
  calleeExpr.pointsTo(calleeValue, originNode) and
  
  // Determine the class type of the callee value
  targetClass = calleeValue.getClass() and
  
  // Pre-filter common non-callable cases before type inference
  not calleeValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, calleeExpr) and
  
  // Verify type inference succeeded and the class is not callable
  not targetClass.failedInference(_) and
  not targetClass.isCallable() and
  
  // Exclude descriptor objects callable via protocol
  not targetClass.hasAttribute("__get__")
select 
  callNode, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  targetClass, 
  targetClass.toString()