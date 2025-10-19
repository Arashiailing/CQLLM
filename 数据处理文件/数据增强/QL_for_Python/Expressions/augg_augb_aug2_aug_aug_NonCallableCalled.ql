/**
 * @name Invocation of non-callable objects
 * @description Detects code that attempts to call objects which are not callable,
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
  Call invocationSite, 
  Value invokedValue, 
  ClassValue invokedClass, 
  Expr invokedExpr, 
  AstNode sourceNode
where
  // Extract the expression being invoked from the function call
  invokedExpr = invocationSite.getFunc() and
  
  // Trace the called expression to its resolved value and origin point
  invokedExpr.pointsTo(invokedValue, sourceNode) and
  
  // Retrieve the class type of the target object
  invokedClass = invokedValue.getClass() and
  
  // Verify the object's class is not callable and type inference was successful
  not invokedClass.isCallable() and
  not invokedClass.failedInference(_) and
  
  // Exclude special cases that might appear non-callable but have valid calling mechanisms
  not (
    // Exclude descriptor objects that implement __get__ method
    // These objects might be callable through the descriptor protocol
    invokedClass.hasAttribute("__get__") or
    
    // Filter out None values as they are explicitly non-callable
    invokedValue = Value::named("None") or
    
    // Special case: exclude NotImplemented when used in raise statements
    use_of_not_implemented_in_raise(_, invokedExpr)
  )
select 
  invocationSite, 
  "Call to a $@ of $@.", 
  sourceNode, 
  "non-callable", 
  invokedClass, 
  invokedClass.toString()