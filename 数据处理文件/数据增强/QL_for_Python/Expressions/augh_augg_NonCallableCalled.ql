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

from Call invocationSite, Expr functionReference, Value targetValue, ClassValue targetClass, AstNode sourceNode
where
  // Extract function reference and its resolved target value
  functionReference = invocationSite.getFunc() and
  functionReference.pointsTo(targetValue, sourceNode) and
  targetClass = targetValue.getClass() and
  
  // Verify the target class is not callable and not a descriptor
  not targetClass.isCallable() and
  not targetClass.failedInference(_) and
  not targetClass.hasAttribute("__get__") and
  
  // Exclude special cases: None and NotImplemented in raise contexts
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, functionReference)
select invocationSite, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()