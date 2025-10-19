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
  Call invocationSite, 
  Expr invokedExpression, 
  Value calledValue, 
  ClassValue calledClass, 
  AstNode sourceNode
where
  // Extract the expression being invoked from the function call
  invokedExpression = invocationSite.getFunc() and
  
  // Trace the called expression to its resolved value and origin point
  invokedExpression.pointsTo(calledValue, sourceNode) and
  
  // Retrieve the class type of the target object
  calledClass = calledValue.getClass() and
  
  // Verify the object's class is not callable
  not calledClass.isCallable() and
  
  // Ensure type inference was successful for accurate analysis
  not calledClass.failedInference(_) and
  
  // Exclude descriptor objects that implement __get__ method
  // These objects might be callable through the descriptor protocol
  not calledClass.hasAttribute("__get__") and
  
  // Filter out None values as they are explicitly non-callable
  not calledValue = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, invokedExpression)
select 
  invocationSite, 
  "Call to a $@ of $@.", 
  sourceNode, 
  "non-callable", 
  calledClass, 
  calledClass.toString()