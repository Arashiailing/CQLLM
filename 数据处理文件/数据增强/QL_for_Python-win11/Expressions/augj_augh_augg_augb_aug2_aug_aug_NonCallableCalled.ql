/**
 * @name Invocation of non-callable objects
 * @description Detects attempts to invoke objects that lack callable behavior,
 *              which would result in TypeError exceptions at runtime.
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
  Call invocationNode, 
  Value resolvedValue, 
  ClassValue objectClass, 
  Expr targetExpression, 
  AstNode valueOrigin
where
  // Extract the expression being invoked at the call site
  targetExpression = invocationNode.getFunc() and
  
  // Resolve the target expression to its concrete value and origin point
  targetExpression.pointsTo(resolvedValue, valueOrigin) and
  
  // Determine the class type of the invoked object
  objectClass = resolvedValue.getClass() and
  
  // Verify the object's class is definitively non-callable
  not objectClass.isCallable() and
  not objectClass.failedInference(_) and
  
  // Filter out special cases that appear non-callable but have valid calling mechanisms
  not (
    // Exclude descriptors implementing __get__ (callable via descriptor protocol)
    objectClass.hasAttribute("__get__") or
    
    // Explicitly exclude None values (known non-callable)
    resolvedValue = Value::named("None") or
    
    // Special handling for NotImplemented in raise statements
    use_of_not_implemented_in_raise(_, targetExpression)
  )
select 
  invocationNode, 
  "Call to a $@ of $@.", 
  valueOrigin, 
  "non-callable", 
  objectClass, 
  objectClass.toString()