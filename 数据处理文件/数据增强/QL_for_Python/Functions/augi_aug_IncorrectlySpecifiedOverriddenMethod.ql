/**
 * @name Mismatch between signature and use of an overridden method
 * @description Identifies methods whose signatures differ from both their overridden methods
 *              and the arguments used in their calls, which may lead to runtime errors.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // Provides core Python code analysis capabilities
import Expressions.CallArgs  // Enables analysis of function call arguments

from Call invocation, FunctionValue parentMethod, FunctionValue childMethod, string problemDescription  // Define data sources for the query
where
  // Filter out constructor methods as they typically have different parameter patterns
  not parentMethod.getName() = "__init__" and
  
  // Verify that the child method actually overrides the parent method
  childMethod.overrides(parentMethod) and
  
  // Retrieve the call node where the child method is invoked
  invocation = childMethod.getAMethodCall().getNode() and
  
  // Ensure the arguments are correct when called as a method
  correct_args_if_called_as_method(invocation, childMethod) and
  
  // Analyze various parameter mismatch scenarios
  (
    // Scenario 1: Insufficient arguments provided
    arg_count(invocation) + 1 < parentMethod.minParameters() and 
    problemDescription = "too few arguments"
    
    or
    
    // Scenario 2: Excessive arguments provided
    arg_count(invocation) >= parentMethod.maxParameters() and 
    problemDescription = "too many arguments"
    
    or
    
    // Scenario 3: Keyword arguments accepted by child but not parent
    exists(string parameterName |
      // Identify keyword argument names in the invocation
      invocation.getAKeyword().getArg() = parameterName and
      
      // Confirm the parameter exists in the child method's parameter list
      childMethod.getScope().getAnArg().(Name).getId() = parameterName and
      
      // Verify the parameter is absent from the parent method's parameter list
      not parentMethod.getScope().getAnArg().(Name).getId() = parameterName and
      
      // Construct the problem description
      problemDescription = "an argument named '" + parameterName + "'"
    )
  )
select parentMethod,  // Select the parent method as the primary result
  "Overridden method signature does not match $@, where it is passed " + problemDescription +
    ". Overriding method $@ matches the call.", invocation, "call", childMethod,  // Generate descriptive error message
  childMethod.descriptiveString()  // Provide detailed description of the child method