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

from Call invocation, FunctionValue parentMethod, FunctionValue childMethod, string mismatchReason
where
  // Exclude constructor methods from analysis
  not parentMethod.getName() = "__init__" and
  
  // Establish inheritance relationship: childMethod overrides parentMethod
  childMethod.overrides(parentMethod) and
  
  // Get the call node that invokes the child method
  invocation = childMethod.getAMethodCall().getNode() and
  
  // Verify that the call arguments match the child method's signature
  correct_args_if_called_as_method(invocation, childMethod) and
  
  // Identify specific signature mismatches between the call and the parent method
  (
    // Case 1: Too few arguments for the parent method
    arg_count(invocation) + 1 < parentMethod.minParameters() and 
    mismatchReason = "too few arguments"
    
    or
    
    // Case 2: Too many arguments for the parent method
    arg_count(invocation) >= parentMethod.maxParameters() and 
    mismatchReason = "too many arguments"
    
    or
    
    // Case 3: Keyword argument exists in child method but not in parent method
    exists(string paramName |
      invocation.getAKeyword().getArg() = paramName and  // Keyword argument in the call
      childMethod.getScope().getAnArg().(Name).getId() = paramName and  // Parameter exists in child method
      not parentMethod.getScope().getAnArg().(Name).getId() = paramName and  // Parameter missing in parent method
      mismatchReason = "an argument named '" + paramName + "'"
    )
  )
select parentMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchReason +
    ". Overriding method $@ matches the call.", invocation, "call", childMethod,
  childMethod.descriptiveString()