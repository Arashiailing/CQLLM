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

from Call methodInvocation, FunctionValue baseFunc, FunctionValue derivedFunc, string mismatchReason
where
  // Exclude constructor methods due to special initialization behavior
  not baseFunc.getName() = "__init__" and
  
  // Verify inheritance relationship: derivedFunc overrides baseFunc
  derivedFunc.overrides(baseFunc) and
  
  // Identify the call site invoking the derived method
  methodInvocation = derivedFunc.getAMethodCall().getNode() and
  
  // Confirm call arguments match derived method's signature
  correct_args_if_called_as_method(methodInvocation, derivedFunc) and
  
  // Detect signature mismatches between call and base method
  (
    // Case 1: Insufficient arguments for base method
    arg_count(methodInvocation) + 1 < baseFunc.minParameters() and 
    mismatchReason = "too few arguments"
    
    or
    
    // Case 2: Excessive arguments for base method
    arg_count(methodInvocation) >= baseFunc.maxParameters() and 
    mismatchReason = "too many arguments"
    
    or
    
    // Case 3: Keyword argument present in derived but absent in base
    exists(string keywordArgName |
      // Keyword argument exists in method call
      methodInvocation.getAKeyword().getArg() = keywordArgName and
      
      // Parameter exists in derived method's signature
      derivedFunc.getScope().getAnArg().(Name).getId() = keywordArgName and
      
      // Parameter missing from base method's signature
      not baseFunc.getScope().getAnArg().(Name).getId() = keywordArgName and
      
      // Format mismatch description with parameter name
      mismatchReason = "an argument named '" + keywordArgName + "'"
    )
  )
select baseFunc,
  "Overridden method signature does not match $@, where it is passed " + mismatchReason +
    ". Overriding method $@ matches the call.", methodInvocation, "call", derivedFunc,
  derivedFunc.descriptiveString()