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
 * This predicate checks that:
 * 1. The lambda consists of a single function call
 * 2. All parameters are passed through without modification
 * 3. No default parameter values are present
 */
predicate isSimpleWrapper(Lambda lambdaExpr, Expr wrappedExpr) {
  exists(Function lambdaFunc, Call funcCall | 
    lambdaFunc = lambdaExpr.getInnerScope() and 
    funcCall = lambdaExpr.getExpression() |
    
    // The function being wrapped
    wrappedExpr = funcCall.getFunc() and
    
    // Verify parameter count matches
    count(lambdaFunc.getAnArg()) = count(funcCall.getAnArg()) and
    
    // Verify parameter names match exactly
    forall(int argIndex | exists(lambdaFunc.getArg(argIndex)) | 
      lambdaFunc.getArgName(argIndex) = funcCall.getArg(argIndex).(Name).getId()
    ) and
    
    // Handle keyword arguments (**kwargs)
    (
      // No keyword arguments in either lambda or call
      not exists(lambdaFunc.getKwarg()) and not exists(funcCall.getKwargs())
      or
      // Keyword arguments match by name
      lambdaFunc.getKwarg().(Name).getId() = funcCall.getKwargs().(Name).getId()
    ) and
    
    // Handle variable arguments (*args)
    (
      // No variable arguments in either lambda or call
      not exists(lambdaFunc.getVararg()) and not exists(funcCall.getStarargs())
      or
      // Variable arguments match by name
      lambdaFunc.getVararg().(Name).getId() = funcCall.getStarargs().(Name).getId()
    ) and
    
    // No named parameters used in the call
    not exists(funcCall.getAKeyword())
  ) and
  
  // Lambda cannot have default values as it wouldn't be a direct replacement
  not exists(lambdaExpr.getArgs().getADefault())
}

/**
 * Identifies lambda expressions that are unnecessary wrappers.
 * A lambda is considered unnecessary when it simply forwards to another callable
 * without modifying parameters, and the target object remains consistent.
 */
predicate isUnnecessaryLambda(Lambda lambdaExpr, Expr targetExpr) {
  isSimpleWrapper(lambdaExpr, targetExpr) and
  (
    // Case 1: Target is a class constructor
    exists(ClassValue classVal | targetExpr.pointsTo(classVal))
    or
    // Case 2: Target is a regular function
    exists(FunctionValue funcVal | targetExpr.pointsTo(funcVal))
    or
    // Case 3: Target is a bound method of enclosing instance
    exists(ClassValue enclosingClass, Attribute attr | 
      enclosingClass.getScope() = lambdaExpr.getScope().getScope() and 
      attr = targetExpr |
      attr.getObject().(Name).getId() = "self" and
      enclosingClass.hasAttribute(attr.getName())
    )
  )
}

from Lambda lambdaExpr, Expr targetExpr
where isUnnecessaryLambda(lambdaExpr, targetExpr)
select lambdaExpr,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."