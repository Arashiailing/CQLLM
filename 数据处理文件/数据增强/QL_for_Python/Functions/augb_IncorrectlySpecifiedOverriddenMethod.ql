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

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string issueDescription
where
  // Exclude constructor methods from analysis
  not baseMethod.getName() = "__init__" and
  
  // Establish inheritance relationship: derivedMethod overrides baseMethod
  derivedMethod.overrides(baseMethod) and
  
  // Get the call node that invokes the derived method
  methodCall = derivedMethod.getAMethodCall().getNode() and
  
  // Verify that the call arguments match the derived method's signature
  correct_args_if_called_as_method(methodCall, derivedMethod) and
  
  // Identify specific signature mismatches between the call and the base method
  (
    // Case 1: Too few arguments for the base method
    arg_count(methodCall) + 1 < baseMethod.minParameters() and 
    issueDescription = "too few arguments"
    
    or
    
    // Case 2: Too many arguments for the base method
    arg_count(methodCall) >= baseMethod.maxParameters() and 
    issueDescription = "too many arguments"
    
    or
    
    // Case 3: Keyword argument exists in derived method but not in base method
    exists(string paramName |
      methodCall.getAKeyword().getArg() = paramName and  // Keyword argument in the call
      derivedMethod.getScope().getAnArg().(Name).getId() = paramName and  // Parameter exists in derived method
      not baseMethod.getScope().getAnArg().(Name).getId() = paramName and  // Parameter missing in base method
      issueDescription = "an argument named '" + paramName + "'"
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + issueDescription +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,
  derivedMethod.descriptiveString()