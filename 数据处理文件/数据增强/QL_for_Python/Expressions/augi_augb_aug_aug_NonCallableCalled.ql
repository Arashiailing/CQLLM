/**
 * @name Non-callable invocation
 * @description Identifies code attempting to invoke non-callable objects,
 *              which results in runtime TypeError exceptions.
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
  Call invocationSite, 
  Value targetValue, 
  ClassValue targetClass, 
  Expr funcExpr, 
  AstNode valueSource
where
  // Extract the function expression from the invocation site
  funcExpr = invocationSite.getFunc() and
  
  // Resolve the function expression to its concrete value and origin
  funcExpr.pointsTo(targetValue, valueSource) and
  
  // Determine the class type of the target value
  targetClass = targetValue.getClass() and
  
  // Verify the target class lacks callable capability
  not targetClass.isCallable() and
  
  // Confirm successful type inference for accurate analysis
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects implementing __get__ protocol
  // which may be callable despite class non-callability
  not targetClass.hasAttribute("__get__") and
  
  // Filter out explicit None values (known non-callables)
  not targetValue = Value::named("None") and
  
  // Special handling: exclude NotImplemented in raise contexts
  not use_of_not_implemented_in_raise(_, funcExpr)
select 
  invocationSite, 
  "Call to a $@ of $@.", 
  valueSource, 
  "non-callable", 
  targetClass, 
  targetClass.toString()