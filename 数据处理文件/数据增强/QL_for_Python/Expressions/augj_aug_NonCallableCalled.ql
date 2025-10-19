/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which will raise a TypeError at runtime.
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
  Value invokedValue, 
  ClassValue targetClass, 
  Expr funcExpr, 
  AstNode originNode
where
  // Extract the function expression from the call site
  funcExpr = callNode.getFunc() and
  
  // Resolve the function expression to its runtime value and origin
  funcExpr.pointsTo(invokedValue, originNode) and
  
  // Identify the class type of the invoked value
  targetClass = invokedValue.getClass() and
  
  // Verify the class type is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference was successful
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ protocol (which might be callable)
  not targetClass.hasAttribute("__get__") and
  
  // Exclude explicit None values (known non-callable)
  not invokedValue = Value::named("None") and
  
  // Exclude NotImplemented in raise statements (special case handling)
  not use_of_not_implemented_in_raise(_, funcExpr)
select 
  callNode, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  targetClass, 
  targetClass.toString()