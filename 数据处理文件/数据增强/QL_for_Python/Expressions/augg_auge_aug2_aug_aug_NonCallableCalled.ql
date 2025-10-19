/**
 * @name Non-callable invoked
 * @description Identifies invocations of objects that cannot be called,
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
  Call invocation, 
  Value calledObject, 
  ClassValue objectClass, 
  Expr calledExpr, 
  AstNode originNode
where
  // Step 1: Extract the function being called from the invocation
  calledExpr = invocation.getFunc() and
  
  // Step 2: Resolve the called expression to its concrete value and origin
  calledExpr.pointsTo(calledObject, originNode) and
  
  // Step 3: Determine the class type of the target object
  objectClass = calledObject.getClass() and
  
  // Step 4: Verify the object's class is not callable
  not objectClass.isCallable() and
  
  // Step 5: Ensure type inference was successful for accurate analysis
  not objectClass.failedInference(_) and
  
  // Step 6: Exclude descriptor objects implementing __get__ method
  // These objects might be callable through the descriptor protocol
  not objectClass.hasAttribute("__get__") and
  
  // Step 7: Filter out None values as they are explicitly non-callable
  not calledObject = Value::named("None") and
  
  // Step 8: Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, calledExpr)
select 
  invocation, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  objectClass, 
  objectClass.toString()