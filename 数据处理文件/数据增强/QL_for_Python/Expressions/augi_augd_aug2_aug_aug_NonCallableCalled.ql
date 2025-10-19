/**
 * @name Non-callable invoked
 * @description Identifies attempts to call objects that do not support callable behavior,
 *              resulting in runtime TypeError exceptions.
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
  Value targetValue, 
  ClassValue objClass, 
  Expr funcExpr, 
  AstNode sourceLocation
where
  // Extract and resolve the function expression being called
  funcExpr = funcCall.getFunc() and
  funcExpr.pointsTo(targetValue, sourceLocation) and
  
  // Determine class and verify it lacks callable behavior
  objClass = targetValue.getClass() and
  not objClass.isCallable() and
  
  // Ensure type inference succeeded for accurate results
  not objClass.failedInference(_) and
  
  // Exclude special cases that might appear non-callable but have valid semantics
  not objClass.hasAttribute("__get__") and
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, funcExpr)
select 
  funcCall, 
  "Call to a $@ of $@.", 
  sourceLocation, 
  "non-callable", 
  objClass, 
  objClass.toString()