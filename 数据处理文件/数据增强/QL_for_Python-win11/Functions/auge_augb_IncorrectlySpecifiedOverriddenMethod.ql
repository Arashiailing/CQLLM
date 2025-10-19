/**
 * @name Mismatch between signature and use of an overridden method
 * @description Identifies methods where signatures differ from both their overridden parent methods
 *              and the actual call arguments. These inconsistencies can cause runtime errors
 *              when the parent method is invoked instead of the child implementation.
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
  // Filter out constructor methods from consideration
  not parentMethod.getName() = "__init__" and
  
  // Establish inheritance relationship: childMethod overrides parentMethod
  childMethod.overrides(parentMethod) and
  
  // Retrieve the invocation node that calls the child method
  methodInvocation = childMethod.getAMethodCall().getNode() and
  
  // Confirm the invocation arguments align with the child method's signature
  correct_args_if_called_as_method(methodInvocation, childMethod) and
  
  // Detect signature mismatches between the invocation and the parent method
  (
    // Scenario 1: Insufficient arguments for the parent method
    arg_count(methodInvocation) + 1 < parentMethod.minParameters() and 
    mismatchType = "too few arguments"
    
    or
    
    // Scenario 2: Excessive arguments for the parent method
    arg_count(methodInvocation) >= parentMethod.maxParameters() and 
    mismatchType = "too many arguments"
    
    or
    
    // Scenario 3: Keyword argument present in child method but absent in parent method
    exists(string paramName |
      methodInvocation.getAKeyword().getArg() = paramName and  // Keyword argument in the invocation
      childMethod.getScope().getAnArg().(Name).getId() = paramName and  // Parameter exists in child method
      not parentMethod.getScope().getAnArg().(Name).getId() = paramName and  // Parameter missing in parent method
      mismatchType = "an argument named '" + paramName + "'"
    )
  )
select parentMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchType +
    ". Overriding method $@ matches the call.", methodInvocation, "call", childMethod,
  childMethod.descriptiveString()