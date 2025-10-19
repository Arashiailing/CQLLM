/**
 * @name Invocation of non-callable objects
 * @description Identifies attempts to call objects that lack callable behavior,
 *              which would cause TypeError exceptions during execution.
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
  Call callSite, 
  Value targetValue, 
  ClassValue targetClass, 
  Expr calledExpr, 
  AstNode originNode
where
  // Identify the expression being invoked at the call site
  calledExpr = callSite.getFunc() and
  
  // Resolve the called expression to its concrete value and origin
  calledExpr.pointsTo(targetValue, originNode) and
  
  // Determine the class type of the invoked object
  targetClass = targetValue.getClass() and
  
  // Verify the object's class is definitively non-callable
  not targetClass.isCallable() and
  not targetClass.failedInference(_) and
  
  // Exclude special cases that appear non-callable but have valid calling mechanisms
  not (
    // Skip descriptors implementing __get__ (callable via descriptor protocol)
    targetClass.hasAttribute("__get__") or
    
    // Explicitly exclude None values (known non-callable)
    targetValue = Value::named("None") or
    
    // Special handling for NotImplemented in raise statements
    use_of_not_implemented_in_raise(_, calledExpr)
  )
select 
  callSite, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  targetClass, 
  targetClass.toString()