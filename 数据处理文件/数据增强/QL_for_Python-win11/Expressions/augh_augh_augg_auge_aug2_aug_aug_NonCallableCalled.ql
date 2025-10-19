/**
 * @name Non-callable invoked
 * @description Detects invocations of objects that lack callability,
 *              which would trigger runtime TypeError exceptions.
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
  Value referencedObject, 
  ClassValue objectType, 
  Expr callableExpr, 
  AstNode sourceLocation
where
  // Identify the expression being invoked in the call
  callableExpr = invocation.getFunc() and
  
  // Resolve the expression to its concrete value and origin
  callableExpr.pointsTo(referencedObject, sourceLocation) and
  
  // Determine the class type of the referenced object
  objectType = referencedObject.getClass() and
  
  // Verify the object's class lacks callability
  not objectType.isCallable() and
  
  // Ensure type inference was successful for accurate analysis
  not objectType.failedInference(_) and
  
  // Exclude descriptor objects implementing __get__ method
  // These objects might be callable through the descriptor protocol
  not objectType.hasAttribute("__get__") and
  
  // Filter out None values as they are explicitly non-callable
  not referencedObject = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, callableExpr)
select 
  invocation, 
  "Call to a $@ of $@.", 
  sourceLocation, 
  "non-callable", 
  objectType, 
  objectType.toString()