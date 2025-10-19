/**
 * @name Non-callable object invocation
 * @description Detects invocations of objects that are not callable,
 *              which would result in a TypeError at runtime.
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
  Value resolvedValue, 
  ClassValue valueClass, 
  Expr calleeExpr, 
  AstNode sourceNode
where
  // Identify the expression being invoked at the call site
  calleeExpr = callSite.getFunc() and
  
  // Resolve the invoked expression to its concrete value and trace its origin
  calleeExpr.pointsTo(resolvedValue, sourceNode) and
  
  // Determine the class type of the resolved value
  valueClass = resolvedValue.getClass() and
  
  // Verify the class is not callable and type inference was successful
  not valueClass.isCallable() and
  not valueClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ method (callable via descriptor protocol)
  not valueClass.hasAttribute("__get__") and
  
  // Exclude explicit None values (known non-callable)
  not resolvedValue = Value::named("None") and
  
  // Exclude special case of NotImplemented in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpr)
select 
  callSite, 
  "Call to a $@ of $@.", 
  sourceNode, 
  "non-callable", 
  valueClass, 
  valueClass.toString()