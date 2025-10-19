/**
 * @name Non-callable invoked
 * @description Detects attempts to call objects that are not callable,
 *              which will cause TypeError exceptions at runtime.
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
  Call callExpr, 
  Value calleeValue, 
  ClassValue calleeClass, 
  Expr calleeExpression, 
  AstNode originNode
where
  // Step 1: Identify the expression being called
  calleeExpression = callExpr.getFunc() and
  
  // Step 2: Resolve the callee to its actual value and origin
  calleeExpression.pointsTo(calleeValue, originNode) and
  
  // Step 3: Get the class of the callee value
  calleeClass = calleeValue.getClass() and
  
  // Step 4: Verify that the class is not callable
  not calleeClass.isCallable() and
  
  // Step 5: Ensure type inference was successful
  not calleeClass.failedInference(_) and
  
  // Step 6: Exclude descriptor objects with __get__ method
  // These might be callable through the descriptor protocol
  not calleeClass.hasAttribute("__get__") and
  
  // Step 7: Exclude None values as they are explicitly non-callable
  not calleeValue = Value::named("None") and
  
  // Step 8: Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpression)
select 
  callExpr, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  calleeClass, 
  calleeClass.toString()