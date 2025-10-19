/**
 * @name Non-callable object invocation
 * @description Identifies attempts to call objects that are not callable,
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

// Find call expressions where the target is not callable
from Call callExpr, Value targetValue, ClassValue targetClass, 
     Expr funcRef, AstNode sourceNode
where
  // Resolve the function reference to its concrete value
  funcRef = callExpr.getFunc() and
  funcRef.pointsTo(targetValue, sourceNode) and
  
  // Determine the class of the invoked value and verify non-callability
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // Exclude cases with incomplete type inference
  not targetClass.failedInference(_) and
  
  // Exclude descriptor protocol objects
  not targetClass.hasAttribute("__get__") and
  
  // Filter out None values
  not targetValue = Value::named("None") and
  
  // Filter out NotImplemented in raise contexts
  not use_of_not_implemented_in_raise(_, funcRef)
select callExpr, "Call to a $@ of $@.", sourceNode, "non-callable", 
       targetClass, targetClass.toString()