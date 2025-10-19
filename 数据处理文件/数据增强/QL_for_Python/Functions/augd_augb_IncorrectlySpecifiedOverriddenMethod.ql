/**
 * @name Mismatch between signature and use of an overridden method
 * @description Detects methods whose signatures differ from both their overridden base methods
 *              and the actual call arguments. Such mismatches can lead to runtime errors
 *              when the base method is called instead of the derived one.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python
import Expressions.CallArgs

from Call methodInvocation, FunctionValue parentMethod, FunctionValue childMethod, string mismatchType
where
  // Exclude constructor methods from analysis
  not parentMethod.getName() = "__init__" and
  
  // Establish inheritance relationship: childMethod overrides parentMethod
  childMethod.overrides(parentMethod) and
  
  // Get the call node that invokes the child method
  methodInvocation = childMethod.getAMethodCall().getNode() and
  
  // Verify that the call arguments match the child method's signature
  correct_args_if_called_as_method(methodInvocation, childMethod) and
  
  // Identify specific signature mismatches between the call and the parent method
  (
    // Case 1: Too few arguments for the parent method
    arg_count(methodInvocation) + 1 < parentMethod.minParameters() and 
    mismatchType = "too few arguments"
    
    or
    
    // Case 2: Too many arguments for the parent method
    arg_count(methodInvocation) >= parentMethod.maxParameters() and 
    mismatchType = "too many arguments"
    
    or
    
    // Case 3: Keyword argument exists in child method but not in parent method
    exists(string paramName |
      // Keyword argument present in the method call
      methodInvocation.getAKeyword().getArg() = paramName and
      
      // Parameter exists in the child method's signature
      childMethod.getScope().getAnArg().(Name).getId() = paramName and
      
      // Parameter missing from the parent method's signature
      not parentMethod.getScope().getAnArg().(Name).getId() = paramName and
      
      // Format the mismatch description with the specific parameter name
      mismatchType = "an argument named '" + paramName + "'"
    )
  )
select parentMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchType +
    ". Overriding method $@ matches the call.", methodInvocation, "call", childMethod,
  childMethod.descriptiveString()