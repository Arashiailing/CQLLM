/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which would raise a TypeError at runtime.
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

// Identify call expressions where the target is not callable
from Call invocationNode, Value invokedValue, ClassValue invokedClass, 
     Expr functionReference, AstNode originNode
where
  // Resolve the function reference to its concrete value
  functionReference = invocationNode.getFunc() and
  functionReference.pointsTo(invokedValue, originNode) and
  
  // Determine the class of the invoked value and verify non-callability
  invokedClass = invokedValue.getClass() and
  not invokedClass.isCallable() and
  
  // Exclude cases with incomplete type inference or descriptor protocol
  not invokedClass.failedInference(_) and
  not invokedClass.hasAttribute("__get__") and
  
  // Filter out None values and NotImplemented in raise contexts
  not invokedValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, functionReference)
select invocationNode, "Call to a $@ of $@.", originNode, "non-callable", 
       invokedClass, invokedClass.toString()