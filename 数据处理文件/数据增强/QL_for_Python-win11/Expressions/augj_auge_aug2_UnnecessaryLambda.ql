/**
 * @name Unnecessary lambda
 * @description Identifies lambda expressions that simply wrap another callable without modifying parameters
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
 * Determines if a lambda expression acts as a direct wrapper around another callable.
 * The lambda must contain only a return statement that forwards parameters
 * unmodified to the target callable.
 */
predicate is_simple_wrapper(Lambda lambdaExpr, Expr wrappedCallable) {
  exists(Function lambdaInnerFunc, Call callExpr | 
    lambdaInnerFunc = lambdaExpr.getInnerScope() and 
    callExpr = lambdaExpr.getExpression() |
    
    // Identify the callable being wrapped
    wrappedCallable = callExpr.getFunc() and
    
    // Verify parameter count matches between lambda and call
    count(lambdaInnerFunc.getAnArg()) = count(callExpr.getAnArg()) and
    
    // Ensure parameter names are identical
    forall(int index | exists(lambdaInnerFunc.getArg(index)) | 
      lambdaInnerFunc.getArgName(index) = callExpr.getArg(index).(Name).getId()
    ) and
    
    // Validate **kwargs handling consistency
    (
      // Case 1: Neither lambda nor call uses **kwargs
      not exists(lambdaInnerFunc.getKwarg()) and not exists(callExpr.getKwargs())
      or
      // Case 2: **kwargs names match
      lambdaInnerFunc.getKwarg().(Name).getId() = callExpr.getKwargs().(Name).getId()
    ) and
    
    // Validate *args handling consistency
    (
      // Case 1: Neither lambda nor call uses *args
      not exists(lambdaInnerFunc.getVararg()) and not exists(callExpr.getStarargs())
      or
      // Case 2: *args names match
      lambdaInnerFunc.getVararg().(Name).getId() = callExpr.getStarargs().(Name).getId()
    ) and
    
    // Prohibit named arguments in the call expression
    not exists(callExpr.getAKeyword())
  ) and
  
  // Exclude lambdas with default parameter values
  not exists(lambdaExpr.getArgs().getADefault())
}

/**
 * Determines if a lambda is unnecessary by confirming it wraps a callable
 * that maintains consistent references between definition and usage contexts.
 */
predicate is_unnecessary_lambda(Lambda lambdaExpr, Expr wrappedNode) {
  // First verify the lambda is a simple wrapper
  is_simple_wrapper(lambdaExpr, wrappedNode) and
  
  // Then verify the wrapped callable maintains consistent references
  (
    // Case 1: Wraps a class
    exists(ClassValue targetClass | wrappedNode.pointsTo(targetClass))
    or
    // Case 2: Wraps a function
    exists(FunctionValue targetFunction | wrappedNode.pointsTo(targetFunction))
    or
    // Case 3: Wraps an instance method from enclosing class
    exists(ClassValue enclosingClass, Attribute methodAccess | 
      enclosingClass.getScope() = lambdaExpr.getScope().getScope() and 
      methodAccess = wrappedNode |
      
      // Verify method is accessed via 'self'
      methodAccess.getObject().(Name).getId() = "self" and
      
      // Confirm class implements the method
      enclosingClass.hasAttribute(methodAccess.getName())
    )
  )
}

from Lambda lambdaExpr, Expr wrappedNode
where is_unnecessary_lambda(lambdaExpr, wrappedNode)
select lambdaExpr,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."