/**
 * @name Invocation of Non-Callable Objects
 * @description Identifies function call expressions where the target object
 *              lacks callable capability, leading to runtime TypeError.
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
  Value callee, 
  ClassValue calleeCls, 
  Expr calleeExpr, 
  AstNode origin
where
  // Extract the function being called
  calleeExpr = callNode.getFunc() and
  
  // Resolve the callee's value and origin
  calleeExpr.pointsTo(callee, origin) and
  
  // Determine the class of the callee
  calleeCls = callee.getClass() and
  
  // Verify the callee's class is not callable
  not calleeCls.isCallable() and
  
  // Ensure type inference succeeded
  not calleeCls.failedInference(_) and
  
  // Exclude descriptor protocol objects
  not calleeCls.hasAttribute("__get__") and
  
  // Exclude explicit None values
  not callee = Value::named("None") and
  
  // Special case: exclude NotImplemented in raise contexts
  not use_of_not_implemented_in_raise(_, calleeExpr)
select 
  callNode, 
  "Call to a $@ of $@.", 
  origin, 
  "non-callable", 
  calleeCls, 
  calleeCls.toString()