/**
 * @name Unnecessary lambda
 * @description Detects lambda expressions that merely wrap another callable without parameter modification
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
 * Identifies lambda expressions serving as simple function wrappers,
 * where the lambda contains only a return statement forwarding parameters
 * directly to another callable without modification.
 */
predicate is_simple_wrapper(Lambda lambdaNode, Expr targetCallable) {
  exists(Function lambdaFunction, Call callNode | 
    lambdaFunction = lambdaNode.getInnerScope() and 
    callNode = lambdaNode.getExpression() |
    
    // Identify the wrapped callable
    targetCallable = callNode.getFunc() and
    
    // Verify parameter count matches
    count(lambdaFunction.getAnArg()) = count(callNode.getAnArg()) and
    
    // Ensure parameter names are identical
    forall(int idx | exists(lambdaFunction.getArg(idx)) | 
      lambdaFunction.getArgName(idx) = callNode.getArg(idx).(Name).getId()
    ) and
    
    // Validate **kwargs consistency
    (
      // Case 1: Neither lambda nor call has **kwargs
      not exists(lambdaFunction.getKwarg()) and not exists(callNode.getKwargs())
      or
      // Case 2: **kwargs names match
      lambdaFunction.getKwarg().(Name).getId() = callNode.getKwargs().(Name).getId()
    ) and
    
    // Validate *args consistency
    (
      // Case 1: Neither lambda nor call has *args
      not exists(lambdaFunction.getVararg()) and not exists(callNode.getStarargs())
      or
      // Case 2: *args names match
      lambdaFunction.getVararg().(Name).getId() = callNode.getStarargs().(Name).getId()
    ) and
    
    // Prohibit named arguments in the call
    not exists(callNode.getAKeyword())
  ) and
  
  // Prevent replacement if lambda has default parameter values
  not exists(lambdaNode.getArgs().getADefault())
}

/**
 * Determines if a lambda is unnecessary by verifying it wraps a callable
 * that remains consistent between lambda creation and execution contexts.
 */
predicate is_unnecessary_lambda(Lambda lambdaNode, Expr wrappedNode) {
  // First verify the lambda is a simple wrapper
  is_simple_wrapper(lambdaNode, wrappedNode) and
  
  // Then verify the wrapped callable maintains consistent references
  (
    // Case 1: Wraps a class
    exists(ClassValue cls | wrappedNode.pointsTo(cls))
    or
    // Case 2: Wraps a function
    exists(FunctionValue funcVal | wrappedNode.pointsTo(funcVal))
    or
    // Case 3: Wraps an instance method from enclosing class
    exists(ClassValue outerClass, Attribute methodAttrExpr | 
      outerClass.getScope() = lambdaNode.getScope().getScope() and 
      methodAttrExpr = wrappedNode |
      
      // Verify method is accessed via 'self'
      methodAttrExpr.getObject().(Name).getId() = "self" and
      
      // Confirm class implements the method
      outerClass.hasAttribute(methodAttrExpr.getName())
    )
  )
}

from Lambda lambdaNode, Expr wrappedNode
where is_unnecessary_lambda(lambdaNode, wrappedNode)
select lambdaNode,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."