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

from Call methodInvocation, FunctionValue parentMethod, FunctionValue childMethod, string mismatchDetails
where
  // Filter out constructor methods as they have special handling
  not parentMethod.getName() = "__init__" and
  
  // Establish inheritance relationship: childMethod overrides parentMethod
  childMethod.overrides(parentMethod) and
  
  // Retrieve the call node that invokes the child method
  methodInvocation = childMethod.getAMethodCall().getNode() and
  
  // Verify compatibility between call arguments and child method's signature
  correct_args_if_called_as_method(methodInvocation, childMethod) and
  
  // Identify specific signature mismatches between the call and the parent method
  (
    // Case 1: Insufficient arguments for the parent method
    arg_count(methodInvocation) + 1 < parentMethod.minParameters() and 
    mismatchDetails = "too few arguments"
    
    or
    
    // Case 2: Excessive arguments for the parent method
    arg_count(methodInvocation) >= parentMethod.maxParameters() and 
    mismatchDetails = "too many arguments"
    
    or
    
    // Case 3: Keyword argument exists in child method but not in parent method
    exists(string parameterName |
      // Keyword argument present in the method invocation
      methodInvocation.getAKeyword().getArg() = parameterName and
      
      // Parameter exists in the child method's signature
      childMethod.getScope().getAnArg().(Name).getId() = parameterName and
      
      // Parameter missing from the parent method's signature
      not parentMethod.getScope().getAnArg().(Name).getId() = parameterName and
      
      mismatchDetails = "an argument named '" + parameterName + "'"
    )
  )
select parentMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchDetails +
    ". Overriding method $@ matches the call.", methodInvocation, "call", childMethod,
  childMethod.descriptiveString()