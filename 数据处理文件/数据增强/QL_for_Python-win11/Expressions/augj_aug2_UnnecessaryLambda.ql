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
 * Identifies lambda expressions that serve as simple wrappers around other functions,
 * where the lambda merely forwards its parameters to the target function without modification.
 */
predicate is_simple_wrapper(Lambda lambdaNode, Expr wrappedFunction) {
  // Lambda must not have default parameters (would prevent direct substitution)
  not exists(lambdaNode.getArgs().getADefault()) and
  
  exists(Function lambdaFunction, Call callNode | 
    lambdaFunction = lambdaNode.getInnerScope() and 
    callNode = lambdaNode.getExpression() |
    
    // Extract the function being called by the lambda
    wrappedFunction = callNode.getFunc() and
    
    // Verify parameter count matches between lambda and wrapped call
    count(lambdaFunction.getAnArg()) = count(callNode.getAnArg()) and
    
    // Ensure all positional parameters are forwarded identically
    forall(int index | exists(lambdaFunction.getArg(index)) | 
      lambdaFunction.getArgName(index) = callNode.getArg(index).(Name).getId()
    ) and
    
    // Validate keyword parameter handling consistency
    (
      // Case 1: Neither lambda nor wrapped call uses **kwargs
      not exists(lambdaFunction.getKwarg()) and not exists(callNode.getKwargs())
      or
      // Case 2: Both use same **kwargs parameter name
      lambdaFunction.getKwarg().(Name).getId() = callNode.getKwargs().(Name).getId()
    ) and
    
    // Validate variadic parameter handling consistency
    (
      // Case 1: Neither lambda nor wrapped call uses *args
      not exists(lambdaFunction.getVararg()) and not exists(callNode.getStarargs())
      or
      // Case 2: Both use same *args parameter name
      lambdaFunction.getVararg().(Name).getId() = callNode.getStarargs().(Name).getId()
    ) and
    
    // Prohibit named arguments in the wrapped call
    not exists(callNode.getAKeyword())
  )
}

/**
 * Determines if a lambda is unnecessary by verifying it wraps a callable
 * that remains consistent between lambda creation and execution contexts.
 */
predicate is_unnecessary_lambda(Lambda lambdaNode, Expr wrappedExpr) {
  // First verify the lambda is a simple wrapper
  is_simple_wrapper(lambdaNode, wrappedExpr) and
  
  // Then confirm the wrapped expression maintains consistent reference
  (
    // Case 1: Wraps a class object
    exists(ClassValue classObj | wrappedExpr.pointsTo(classObj))
    or
    // Case 2: Wraps a function object
    exists(FunctionValue funcObj | wrappedExpr.pointsTo(funcObj))
    or
    // Case 3: Wraps an instance method from enclosing class
    exists(ClassValue enclosingClass, Attribute methodAttr | 
      enclosingClass.getScope() = lambdaNode.getScope().getScope() and 
      methodAttr = wrappedExpr |
      
      // Verify method is accessed via 'self'
      methodAttr.getObject().(Name).getId() = "self" and
      
      // Confirm class implements the method
      enclosingClass.hasAttribute(methodAttr.getName())
    )
  )
}

from Lambda lambdaNode, Expr wrappedExpr
where is_unnecessary_lambda(lambdaNode, wrappedExpr)
select lambdaNode,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."