/**
 * @name Mismatch between signature and use of an overridden method
 * @description Identifies methods where the signature differs from both their overridden base methods
 *              and the actual call arguments. These mismatches can cause runtime errors when
 *              the base method is called instead of the derived one.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python
import Expressions.CallArgs

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string mismatchDescription
where
  // Exclude constructor methods due to special initialization handling
  not baseMethod.getName() = "__init__" and
  
  // Establish inheritance relationship where derivedMethod overrides baseMethod
  derivedMethod.overrides(baseMethod) and
  
  // Identify the specific call node invoking the derived method
  methodCall = derivedMethod.getAMethodCall().getNode() and
  
  // Verify call arguments are compatible with derived method's signature
  correct_args_if_called_as_method(methodCall, derivedMethod) and
  
  // Detect signature mismatches between call arguments and base method
  (
    // Insufficient arguments for base method's minimum parameter requirement
    arg_count(methodCall) + 1 < baseMethod.minParameters() and 
    mismatchDescription = "too few arguments"
    
    or
    
    // Excessive arguments exceeding base method's maximum parameter limit
    arg_count(methodCall) >= baseMethod.maxParameters() and 
    mismatchDescription = "too many arguments"
    
    or
    
    // Keyword argument present in derived method but absent in base method
    exists(string parameterName |
      // Keyword argument exists in method invocation
      methodCall.getAKeyword().getArg() = parameterName and
      
      // Parameter exists in derived method's signature
      derivedMethod.getScope().getAnArg().(Name).getId() = parameterName and
      
      // Parameter missing from base method's signature
      not baseMethod.getScope().getAnArg().(Name).getId() = parameterName and
      
      mismatchDescription = "an argument named '" + parameterName + "'"
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchDescription +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,
  derivedMethod.descriptiveString()