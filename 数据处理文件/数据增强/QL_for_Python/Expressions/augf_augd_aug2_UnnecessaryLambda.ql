/**
 * @name Unnecessary lambda
 * @description Detects lambda expressions that merely forward calls to another callable without parameter modification
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
 * Identifies lambda expressions serving as simple pass-through wrappers.
 * Criteria for simple wrappers:
 * 1. Contains only a single call expression
 * 2. Forwards all parameters without modification
 * 3. Lacks parameter defaults
 */
predicate is_simple_wrapper(Lambda lambdaExpr, Expr targetFunc) {
  exists(Function lambdaFunc, Call callNode | 
    lambdaFunc = lambdaExpr.getInnerScope() and 
    callNode = lambdaExpr.getExpression() |
    
    // Establish the callable being wrapped
    targetFunc = callNode.getFunc() and
    
    // Validate parameter count consistency
    count(lambdaFunc.getAnArg()) = count(callNode.getAnArg()) and
    
    // Verify direct forwarding of positional parameters
    forall(int index | exists(lambdaFunc.getArg(index)) | 
      lambdaFunc.getArgName(index) = callNode.getArg(index).(Name).getId()
    ) and
    
    // Handle **kwargs consistency
    (
      // Neither uses **kwargs
      not exists(lambdaFunc.getKwarg()) and not exists(callNode.getKwargs())
      or
      // Both use identical **kwargs name
      lambdaFunc.getKwarg().(Name).getId() = callNode.getKwargs().(Name).getId()
    ) and
    
    // Handle *args consistency
    (
      // Neither uses *args
      not exists(lambdaFunc.getVararg()) and not exists(callNode.getStarargs())
      or
      // Both use identical *args name
      lambdaFunc.getVararg().(Name).getId() = callNode.getStarargs().(Name).getId()
    ) and
    
    // Prohibit named arguments in call
    not exists(callNode.getAKeyword())
  ) and
  
  // Exclude lambdas with default parameters
  not exists(lambdaExpr.getArgs().getADefault())
}

/**
 * Identifies replaceable lambda expressions by verifying target accessibility.
 * Valid targets include:
 * 1. Class instances
 * 2. Standalone functions
 * 3. Bound methods of enclosing class
 */
predicate is_unnecessary_lambda(Lambda lambdaExpr, Expr wrappedFunc) {
  // Confirm simple wrapper behavior
  is_simple_wrapper(lambdaExpr, wrappedFunc) and
  
  // Verify target accessibility
  (
    // Case 1: Target is a class
    exists(ClassValue classObj | wrappedFunc.pointsTo(classObj))
    or
    // Case 2: Target is a function
    exists(FunctionValue funcObj | wrappedFunc.pointsTo(funcObj))
    or
    // Case 3: Target is bound method of enclosing class
    exists(ClassValue enclosingClass, Attribute methodAttr | 
      enclosingClass.getScope() = lambdaExpr.getScope().getScope() and 
      methodAttr = wrappedFunc |
      
      // Verify 'self' reference
      methodAttr.getObject().(Name).getId() = "self" and
      
      // Confirm class ownership
      enclosingClass.hasAttribute(methodAttr.getName())
    )
  )
}

from Lambda lambdaExpr, Expr wrappedFunc
where is_unnecessary_lambda(lambdaExpr, wrappedFunc)
select lambdaExpr,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."