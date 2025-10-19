/**
 * @name Unnecessary lambda
 * @description Detects lambda expressions that simply forward parameters to another function without modification
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
 * Identifies lambda expressions that act as direct function wrappers,
 * where the lambda only returns a function call with identical parameters
 * and no parameter transformation occurs.
 */
predicate is_direct_function_wrapper(Lambda lambdaNode, Expr targetFunc) {
  exists(Function innerFunc, Call callExpr | 
    innerFunc = lambdaNode.getInnerScope() and 
    callExpr = lambdaNode.getExpression() |
    
    // Identify the target function being called
    targetFunc = callExpr.getFunc() and
    
    // Verify parameter count matches between lambda and call
    count(innerFunc.getAnArg()) = count(callExpr.getAnArg()) and
    
    // Ensure parameter names are identical
    forall(int argIndex | exists(innerFunc.getArg(argIndex)) | 
      innerFunc.getArgName(argIndex) = callExpr.getArg(argIndex).(Name).getId()
    ) and
    
    // Validate keyword arguments consistency
    (
      // Case 1: Neither lambda nor call uses **kwargs
      not exists(innerFunc.getKwarg()) and not exists(callExpr.getKwargs())
      or
      // Case 2: Both use same **kwargs name
      innerFunc.getKwarg().(Name).getId() = callExpr.getKwargs().(Name).getId()
    ) and
    
    // Validate positional arguments consistency
    (
      // Case 1: Neither lambda nor call uses *args
      not exists(innerFunc.getVararg()) and not exists(callExpr.getStarargs())
      or
      // Case 2: Both use same *args name
      innerFunc.getVararg().(Name).getId() = callExpr.getStarargs().(Name).getId()
    ) and
    
    // Prohibit named arguments in function call
    not exists(callExpr.getAKeyword())
  ) and
  
  // Exclude lambdas with default parameter values
  not exists(lambdaNode.getArgs().getADefault())
}

/**
 * Determines if a lambda expression is redundant by verifying
 * that the wrapped expression maintains consistent object references
 * between lambda creation and execution contexts.
 */
predicate is_redundant_lambda(Lambda lambdaNode, Expr targetExpr) {
  // First verify lambda is a direct function wrapper
  is_direct_function_wrapper(lambdaNode, targetExpr) and
  
  // Then confirm wrapped expression has stable object references
  (
    // Case 1: Wraps a class object
    exists(ClassValue classObj | targetExpr.pointsTo(classObj))
    or
    // Case 2: Wraps a function object
    exists(FunctionValue funcObj | targetExpr.pointsTo(funcObj))
    or
    // Case 3: Wraps bound method from enclosing instance
    exists(ClassValue enclosingClass, Attribute methodAttr | 
      enclosingClass.getScope() = lambdaNode.getScope().getScope() and 
      methodAttr = targetExpr |
      
      // Verify method is called on 'self'
      methodAttr.getObject().(Name).getId() = "self" and
      
      // Confirm class owns the method
      enclosingClass.hasAttribute(methodAttr.getName())
    )
  )
}

from Lambda lambdaNode, Expr targetExpr
where is_redundant_lambda(lambdaNode, targetExpr)
select lambdaNode,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."