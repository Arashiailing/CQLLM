/**
 * @name Unnecessary lambda
 * @description Identifies lambda expressions that merely pass parameters to another function without any modification.
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
 * Detects lambda expressions serving as direct function wrappers,
 * which solely return a function call using the same parameters
 * without performing any transformation on them.
 */
predicate is_direct_function_wrapper(Lambda lambdaExpr, Expr calledFunc) {
  exists(Function innerFunction, Call functionCall | 
    innerFunction = lambdaExpr.getInnerScope() and 
    functionCall = lambdaExpr.getExpression() |
    
    // Identify the target function being called
    calledFunc = functionCall.getFunc() and
    
    // Verify parameter count matches between lambda and call
    count(innerFunction.getAnArg()) = count(functionCall.getAnArg()) and
    
    // Ensure parameter names are identical
    forall(int index | exists(innerFunction.getArg(index)) | 
      innerFunction.getArgName(index) = functionCall.getArg(index).(Name).getId()
    ) and
    
    // Validate keyword arguments consistency
    (
      // Case 1: Neither lambda nor call uses **kwargs
      not exists(innerFunction.getKwarg()) and not exists(functionCall.getKwargs())
      or
      // Case 2: Both use same **kwargs name
      innerFunction.getKwarg().(Name).getId() = functionCall.getKwargs().(Name).getId()
    ) and
    
    // Validate positional arguments consistency
    (
      // Case 1: Neither lambda nor call uses *args
      not exists(innerFunction.getVararg()) and not exists(functionCall.getStarargs())
      or
      // Case 2: Both use same *args name
      innerFunction.getVararg().(Name).getId() = functionCall.getStarargs().(Name).getId()
    ) and
    
    // Prohibit named arguments in function call
    not exists(functionCall.getAKeyword())
  ) and
  
  // Exclude lambdas with default parameter values
  not exists(lambdaExpr.getArgs().getADefault())
}

/**
 * Checks whether a lambda expression is redundant by ensuring
 * that the wrapped expression maintains stable object references
 * across the contexts where the lambda is created and executed.
 */
predicate is_redundant_lambda(Lambda lambdaExpr, Expr wrappedExpr) {
  // First verify lambda is a direct function wrapper
  is_direct_function_wrapper(lambdaExpr, wrappedExpr) and
  
  // Then confirm wrapped expression has stable object references
  (
    // Case 1: Wraps a function object
    exists(FunctionValue func | wrappedExpr.pointsTo(func))
    or
    // Case 2: Wraps a class object
    exists(ClassValue cls | wrappedExpr.pointsTo(cls))
    or
    // Case 3: Wraps bound method from enclosing instance
    exists(ClassValue parentClass, Attribute method | 
      parentClass.getScope() = lambdaExpr.getScope().getScope() and 
      method = wrappedExpr |
      
      // Verify method is called on 'self'
      method.getObject().(Name).getId() = "self" and
      
      // Confirm class owns the method
      parentClass.hasAttribute(method.getName())
    )
  )
}

from Lambda lambdaExpr, Expr wrappedExpr
where is_redundant_lambda(lambdaExpr, wrappedExpr)
select lambdaExpr,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."