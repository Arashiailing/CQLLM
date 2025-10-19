/**
 * @name Method signature and call argument mismatch in overridden methods
 * @description Identifies situations where a method's signature differs from both 
 *              its overridden parent method and the arguments used in its invocations,
 *              which may lead to runtime errors.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python
import Expressions.CallArgs

from Call invocationNode, FunctionValue baseMethod, FunctionValue derivedMethod, string errorMsg
where
  // Exclude constructor methods as they typically have different parameter patterns
  not baseMethod.getName() = "__init__" and
  
  // Verify that the derived method actually overrides the base method
  derivedMethod.overrides(baseMethod) and
  
  // Retrieve the invocation node of the derived method
  invocationNode = derivedMethod.getAMethodCall().getNode() and
  
  // Ensure the method call uses correct arguments when called as a method
  correct_args_if_called_as_method(invocationNode, derivedMethod) and
  
  // Analyze different types of parameter mismatches
  (
    // Case 1: Number of arguments passed is less than the minimum required by base method
    (arg_count(invocationNode) + 1 < baseMethod.minParameters() and 
     errorMsg = "too few arguments")
    
    or
    
    // Case 2: Number of arguments passed exceeds the maximum allowed by base method
    (arg_count(invocationNode) >= baseMethod.maxParameters() and 
     errorMsg = "too many arguments")
    
    or
    
    // Case 3: Keyword argument exists that is accepted by derived but not by base method
    exists(string paramName |
      // Identify keyword argument name in the invocation
      invocationNode.getAKeyword().getArg() = paramName and
      
      // Confirm this parameter exists in derived method's parameter list
      derivedMethod.getScope().getAnArg().(Name).getId() = paramName and
      
      // Verify this parameter does not exist in base method's parameter list
      not baseMethod.getScope().getAnArg().(Name).getId() = paramName and
      
      // Construct error message with the problematic parameter name
      errorMsg = "an argument named '" + paramName + "'"
    )
  )
select baseMethod, 
  "Overridden method signature does not match $@, where it is passed " + errorMsg +
    ". Overriding method $@ matches the call.", invocationNode, "call", derivedMethod,
  derivedMethod.descriptiveString()