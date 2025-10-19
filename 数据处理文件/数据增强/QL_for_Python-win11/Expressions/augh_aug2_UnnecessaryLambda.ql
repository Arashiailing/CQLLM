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
 * 判断 lambda 表达式是否为简单包装器。
 * 简单包装器指 lambda 仅包含一个返回语句，该语句调用另一个函数，
 * 且 lambda 的参数直接传递给被调用函数，不做任何修改。
 */
predicate simple_wrapper(Lambda lambdaNode, Expr wrappedFunction) {
  exists(Function lambdaBody, Call functionCall | 
    lambdaBody = lambdaNode.getInnerScope() and 
    functionCall = lambdaNode.getExpression() |
    
    // 获取被调用的函数
    wrappedFunction = functionCall.getFunc() and
    
    // 检查参数数量是否相同
    count(lambdaBody.getAnArg()) = count(functionCall.getAnArg()) and
    
    // 检查参数名称是否相同
    forall(int argIndex | exists(lambdaBody.getArg(argIndex)) | 
      lambdaBody.getArgName(argIndex) = functionCall.getArg(argIndex).(Name).getId()
    ) and
    
    // 检查 **kwargs 参数是否匹配
    (
      // 情况1: lambda 和函数调用都没有 **kwargs
      not exists(lambdaBody.getKwarg()) and not exists(functionCall.getKwargs())
      or
      // 情况2: lambda 和函数调用的 **kwargs 名称相同
      lambdaBody.getKwarg().(Name).getId() = functionCall.getKwargs().(Name).getId()
    ) and
    
    // 检查 *args 参数是否匹配
    (
      // 情况1: lambda 和函数调用都没有 *args
      not exists(lambdaBody.getVararg()) and not exists(functionCall.getStarargs())
      or
      // 情况2: lambda 和函数调用的 *args 名称相同
      lambdaBody.getVararg().(Name).getId() = functionCall.getStarargs().(Name).getId()
    ) and
    
    // 确保函数调用中没有使用命名参数
    not exists(functionCall.getAKeyword())
  ) and
  
  // 如果 lambda 有默认参数值，则不能直接替换为被调用函数
  not exists(lambdaNode.getArgs().getADefault())
}

/**
 * 判断 lambda 表达式是否是不必要的，
 * 即它包装了一个在 lambda 创建时和执行时都指向同一对象的表达式。
 */
predicate unnecessary_lambda(Lambda lambdaNode, Expr wrappedTarget) {
  // 首先检查 lambda 是否是一个简单的包装器
  simple_wrapper(lambdaNode, wrappedTarget) and
  
  // 然后检查被包装的表达式在 lambda 创建时和执行时是否指向同一对象
  (
    // 情况1: 包装了一个普通类
    exists(ClassValue classObj | wrappedTarget.pointsTo(classObj))
    or
    // 情况2: 包装了一个普通函数
    exists(FunctionValue funcObj | wrappedTarget.pointsTo(funcObj))
    or
    // 情况3: 包装了封闭实例的绑定方法
    exists(ClassValue enclosingClass, Attribute methodAttr | 
      enclosingClass.getScope() = lambdaNode.getScope().getScope() and 
      methodAttr = wrappedTarget |
      
      // 检查方法的对象是 self
      methodAttr.getObject().(Name).getId() = "self" and
      
      // 检查类具有该属性
      enclosingClass.hasAttribute(methodAttr.getName())
    )
  )
}

from Lambda lambdaNode, Expr wrappedTarget
where unnecessary_lambda(lambdaNode, wrappedTarget)
select lambdaNode,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."