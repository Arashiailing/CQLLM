/**
 * @name Non-callable called
 * @description Identifies calls to objects that lack callable behavior, 
 *              which would trigger a TypeError during execution.
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
  Expr calleeExpr,
  Value calleeValue,
  ClassValue calleeClass,
  AstNode originNode
where
  // Extract the function expression from the call site
  calleeExpr = callSite.getFunc() and
  
  // Resolve the callee expression to its concrete value and origin
  calleeExpr.pointsTo(calleeValue, originNode) and
  
  // Determine the class type of the callee value
  calleeClass = calleeValue.getClass() and
  
  // Core check: verify the class is not callable
  not calleeClass.isCallable() and
  
  // Exclude cases where type inference failed
  not calleeClass.failedInference(_) and
  
  // Exclude descriptors with __get__ protocol (may be callable indirectly)
  not calleeClass.hasAttribute("__get__") and
  
  // Explicitly exclude None values
  not calleeValue = Value::named("None") and
  
  // Special handling: exclude NotImplemented in raise contexts
  not use_of_not_implemented_in_raise(_, calleeExpr)
select 
  callSite, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  calleeClass, 
  calleeClass.toString()