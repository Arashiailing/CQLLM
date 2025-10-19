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
 * 检查一个 lambda 表达式是否仅作为简单包装器使用，
 * 即 lambda 仅包含一个返回语句，该语句调用另一个函数，
 * 且 lambda 的参数直接传递给被调用函数，不做任何修改。
 */
predicate is_simple_wrapper(Lambda lambdaNode, Expr wrappedFunction) {
  exists(Function lambdaFunction, Call functionCall | 
    lambdaFunction = lambdaNode.getInnerScope() and 
    functionCall = lambdaNode.getExpression() |
    
    // 获取被调用的函数
    wrappedFunction = functionCall.getFunc() and
    
    // 检查参数数量是否相同
    count(lambdaFunction.getAnArg()) = count(functionCall.getAnArg()) and
    
    // 检查参数名称是否相同
    forall(int argIndex | exists(lambdaFunction.getArg(argIndex)) | 
      lambdaFunction.getArgName(argIndex) = functionCall.getArg(argIndex).(Name).getId()
    ) and
    
    // 检查 **kwargs 参数是否匹配
    (
      // 情况1: lambda 和函数调用都没有 **kwargs
      not exists(lambdaFunction.getKwarg()) and not exists(functionCall.getKwargs())
      or
      // 情况2: lambda 和函数调用的 **kwargs 名称相同
      lambdaFunction.getKwarg().(Name).getId() = functionCall.getKwargs().(Name).getId()
    ) and
    
    // 检查 *args 参数是否匹配
    (
      // 情况1: lambda 和函数调用都没有 *args
      not exists(lambdaFunction.getVararg()) and not exists(functionCall.getStarargs())
      or
      // 情况2: lambda 和函数调用的 *args 名称相同
      lambdaFunction.getVararg().(Name).getId() = functionCall.getStarargs().(Name).getId()
    ) and
    
    // 确保函数调用中没有使用命名参数
    not exists(functionCall.getAKeyword())
  ) and
  
  // 如果 lambda 有默认参数值，则不能直接替换为被调用函数
  not exists(lambdaNode.getArgs().getADefault())
}

/**
 * 检查一个 lambda 表达式是否是不必要的，
 * 即它包装了一个在 lambda 创建时和执行时都指向同一对象的表达式。
 */
predicate is_unnecessary_lambda(Lambda lambdaNode, Expr targetExpr) {
  // 首先检查 lambda 是否是一个简单的包装器
  is_simple_wrapper(lambdaNode, targetExpr) and
  
  // 然后检查被包装的表达式在 lambda 创建时和执行时是否指向同一对象
  (
    // 情况1: 包装了一个普通类
    exists(ClassValue targetClass | targetExpr.pointsTo(targetClass))
    or
    // 情况2: 包装了一个普通函数
    exists(FunctionValue funcValue | targetExpr.pointsTo(funcValue))
    or
    // 情况3: 包装了封闭实例的绑定方法
    exists(ClassValue parentClass, Attribute methodAttr | 
      parentClass.getScope() = lambdaNode.getScope().getScope() and 
      methodAttr = targetExpr |
      
      // 检查方法的对象是 self
      methodAttr.getObject().(Name).getId() = "self" and
      
      // 检查类具有该属性
      parentClass.hasAttribute(methodAttr.getName())
    )
  )
}

from Lambda lambdaNode, Expr targetExpr
where is_unnecessary_lambda(lambdaNode, targetExpr)
select lambdaNode,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."