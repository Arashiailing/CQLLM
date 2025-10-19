/**
 * @name Unnecessary lambda
 * @description A lambda is used that calls through to a function without modifying any parameters
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/unnecessary-lambda
 */

import python

/**
 * Determines if a lambda expression is a simple wrapper around another callable.
 * A simple wrapper:
 * 1. Contains only a single call expression
 * 2. Passes all parameters directly without modification
 * 3. Has no parameter defaults
 */
predicate is_simple_wrapper(Lambda lambdaNode, Expr targetCallable) {
  exists(Function lambdaFunction, Call callExpr | 
    lambdaFunction = lambdaNode.getInnerScope() and 
    callExpr = lambdaNode.getExpression() |
    
    // Identify the target callable being invoked
    targetCallable = callExpr.getFunc() and
    
    // Verify parameter count matches between lambda and call
    count(lambdaFunction.getAnArg()) = count(callExpr.getAnArg()) and
    
    // Ensure all positional parameters are passed through unchanged
    forall(int index | exists(lambdaFunction.getArg(index)) | 
      lambdaFunction.getArgName(index) = callExpr.getArg(index).(Name).getId()
    ) and
    
    // Validate **kwargs handling consistency
    (
      // Case 1: Neither lambda nor call uses **kwargs
      not exists(lambdaFunction.getKwarg()) and not exists(callExpr.getKwargs())
      or
      // Case 2: Both use same **kwargs name
      lambdaFunction.getKwarg().(Name).getId() = callExpr.getKwargs().(Name).getId()
    ) and
    
    // Validate *args handling consistency
    (
      // Case 1: Neither lambda nor call uses *args
      not exists(lambdaFunction.getVararg()) and not exists(callExpr.getStarargs())
      or
      // Case 2: Both use same *args name
      lambdaFunction.getVararg().(Name).getId() = callExpr.getStarargs().(Name).getId()
    ) and
    
    // Prohibit named arguments in the call expression
    not exists(callExpr.getAKeyword())
  ) and
  
  // Exclude lambdas with default parameter values
  not exists(lambdaNode.getArgs().getADefault())
}

/**
 * Identifies unnecessary lambda expressions that can be replaced
 * with their target callable. This requires the target to be:
 * 1. A class instance
 * 2. A standalone function
 * 3. A bound method of the enclosing class
 */
predicate is_unnecessary_lambda(Lambda lambdaNode, Expr wrappedCallable) {
  // First verify the lambda is a simple wrapper
  is_simple_wrapper(lambdaNode, wrappedCallable) and
  
  // Then verify the target is consistently accessible
  (
    // Case 1: Target is a class
    exists(ClassValue classValue | wrappedCallable.pointsTo(classValue))
    or
    // Case 2: Target is a function
    exists(FunctionValue functionValue | wrappedCallable.pointsTo(functionValue))
    or
    // Case 3: Target is a bound method of enclosing class
    exists(ClassValue enclosingClassValue, Attribute methodAttribute | 
      enclosingClassValue.getScope() = lambdaNode.getScope().getScope() and 
      methodAttribute = wrappedCallable |
      
      // Verify method is accessed via 'self'
      methodAttribute.getObject().(Name).getId() = "self" and
      
      // Confirm class owns the method
      enclosingClassValue.hasAttribute(methodAttribute.getName())
    )
  )
}

from Lambda lambdaNode, Expr wrappedCallable
where is_unnecessary_lambda(lambdaNode, wrappedCallable)
select lambdaNode,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."