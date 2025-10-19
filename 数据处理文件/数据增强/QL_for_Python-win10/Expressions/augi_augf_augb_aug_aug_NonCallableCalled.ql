/**
 * @name Invocation of non-callable objects
 * @description Identifies code that attempts to invoke objects which are not callable,
 *              potentially causing TypeError exceptions at runtime.
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
  Value invokedValue, 
  ClassValue valueClass, 
  Expr calleeExpr, 
  AstNode sourceNode
where
  // Extract the expression being called from the invocation site
  calleeExpr = callSite.getFunc() and
  
  // Resolve the callee expression to its concrete value and origin
  calleeExpr.pointsTo(invokedValue, sourceNode) and
  
  // Determine the class of the invoked value
  valueClass = invokedValue.getClass() and
  
  // Verify the value's class is not callable
  not valueClass.isCallable() and
  
  // Ensure successful type inference for accurate analysis
  not valueClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ method (callable via protocol)
  not valueClass.hasAttribute("__get__") and
  
  // Filter out explicit None values (known non-callable)
  not invokedValue = Value::named("None") and
  
  // Special case: exclude NotImplemented in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpr)
select 
  callSite, 
  "Call to a $@ of $@.", 
  sourceNode, 
  "non-callable", 
  valueClass, 
  valueClass.toString()