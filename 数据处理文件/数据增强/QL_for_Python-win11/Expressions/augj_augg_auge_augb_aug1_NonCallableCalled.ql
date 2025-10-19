/**
 * @name Non-callable called
 * @description Identifies instances where non-callable objects are invoked as functions,
 *              which would result in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable */

import python
import Exceptions.NotImplemented

// Main query variables: function call expression, target value, its class, callee expression, and source node
from Call functionCall, Value targetValue, ClassValue targetClass, 
     Expr calleeExpr, AstNode sourceNode
where
  // Extract the function reference from the call and determine what value it points to
  calleeExpr = functionCall.getFunc() and
  calleeExpr.pointsTo(targetValue, sourceNode) and
  
  // Analyze the class characteristics of the target value
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  not targetClass.failedInference(_) and
  
  // Filter out special protocol objects and specific values that should be excluded
  not targetClass.hasAttribute("__get__") and
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, calleeExpr)
select functionCall, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()