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
  Call invocation,
  Expr targetExpr,
  Value targetValue,
  ClassValue targetClass,
  AstNode valueOrigin
where
  // Resolve the call target expression and its concrete value
  targetExpr = invocation.getFunc() and
  targetExpr.pointsTo(targetValue, valueOrigin) and
  
  // Determine the class type of the target value
  targetClass = targetValue.getClass() and
  
  // Core check: verify the class lacks callable behavior
  not targetClass.isCallable() and
  
  // Filter out cases where type inference failed
  not targetClass.failedInference(_) and
  
  // Exclude descriptors with __get__ protocol (indirectly callable)
  not targetClass.hasAttribute("__get__") and
  
  // Explicitly exclude None values
  not targetValue = Value::named("None") and
  
  // Special handling: exclude NotImplemented in raise contexts
  not use_of_not_implemented_in_raise(_, targetExpr)
select 
  invocation, 
  "Call to a $@ of $@.", 
  valueOrigin, 
  "non-callable", 
  targetClass, 
  targetClass.toString()