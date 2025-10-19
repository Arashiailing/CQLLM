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

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string mismatchDetail
where
  // Skip constructor methods as they have special initialization behavior
  not baseMethod.getName() = "__init__" and
  
  // Verify inheritance relationship: derivedMethod overrides baseMethod
  derivedMethod.overrides(baseMethod) and
  
  // Identify the call site that invokes the derived method
  methodCall = derivedMethod.getAMethodCall().getNode() and
  
  // Confirm the call arguments match the derived method's signature
  correct_args_if_called_as_method(methodCall, derivedMethod) and
  
  // Detect signature mismatches between the call and the base method
  (
    // Case 1: Insufficient arguments provided for the base method
    arg_count(methodCall) + 1 < baseMethod.minParameters() and 
    mismatchDetail = "too few arguments"
    
    or
    
    // Case 2: Excessive arguments provided for the base method
    arg_count(methodCall) >= baseMethod.maxParameters() and 
    mismatchDetail = "too many arguments"
    
    or
    
    // Case 3: Keyword argument present in derived method but absent in base method
    exists(string argName |
      // Keyword argument exists in the method call
      methodCall.getAKeyword().getArg() = argName and
      
      // Parameter exists in the derived method's signature
      derivedMethod.getScope().getAnArg().(Name).getId() = argName and
      
      // Parameter is missing from the base method's signature
      not baseMethod.getScope().getAnArg().(Name).getId() = argName and
      
      // Format the mismatch description with the specific parameter name
      mismatchDetail = "an argument named '" + argName + "'"
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchDetail +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,
  derivedMethod.descriptiveString()