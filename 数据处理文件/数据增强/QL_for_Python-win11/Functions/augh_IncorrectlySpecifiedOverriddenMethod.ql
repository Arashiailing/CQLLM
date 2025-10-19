/**
 * @name Mismatch between signature and use of an overridden method
 * @description Detects methods with signatures that differ from both their overridden methods
 *              and the arguments used in calls, indicating potential runtime errors.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python
import Expressions.CallArgs

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string problemDescription
where
  // Exclude constructor methods from analysis
  not baseMethod.getName() = "__init__" and
  
  // Verify inheritance relationship: derivedMethod overrides baseMethod
  derivedMethod.overrides(baseMethod) and
  
  // Identify the specific call node invoking the derived method
  methodCall = derivedMethod.getAMethodCall().getNode() and
  
  // Validate that call arguments match the derived method's signature
  correct_args_if_called_as_method(methodCall, derivedMethod) and
  
  // Detect signature mismatches between base method and call arguments
  (
    // Case 1: Insufficient arguments for base method
    arg_count(methodCall) + 1 < baseMethod.minParameters() and 
    problemDescription = "too few arguments"
    
    or
    
    // Case 2: Excessive arguments for base method
    arg_count(methodCall) >= baseMethod.maxParameters() and 
    problemDescription = "too many arguments"
    
    or
    
    // Case 3: Keyword argument exists in derived method but not in base method
    exists(string paramName |
      methodCall.getAKeyword().getArg() = paramName and  // Keyword argument in call
      derivedMethod.getScope().getAnArg().(Name).getId() = paramName and  // Exists in derived method
      not baseMethod.getScope().getAnArg().(Name).getId() = paramName and  // Missing in base method
      problemDescription = "an argument named '" + paramName + "'"
    )
  )
select baseMethod, 
  "Overridden method signature does not match $@, where it is passed " + problemDescription +
    ". Overriding method $@ matches the call.", 
  methodCall, "call", derivedMethod, 
  derivedMethod.descriptiveString()