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
 * 检查一个 lambda 表达式是否是一个简单的包装器，
 * 即 lambda 仅包含一个返回语句，该语句调用另一个函数，
 * 且 lambda 的参数直接传递给被调用函数，不做任何修改。
 */
predicate simple_wrapper(Lambda lambdaExpr, Expr targetFunction) {
  exists(Function lambdaFunc, Call funcCall | 
    lambdaFunc = lambdaExpr.getInnerScope() and 
    funcCall = lambdaExpr.getExpression() |
    
    // 获取被调用的函数
    targetFunction = funcCall.getFunc() and
    
    // 检查参数数量是否相同
    count(lambdaFunc.getAnArg()) = count(funcCall.getAnArg()) and
    
    // 检查参数名称是否相同
    forall(int argIndex | exists(lambdaFunc.getArg(argIndex)) | 
      lambdaFunc.getArgName(argIndex) = funcCall.getArg(argIndex).(Name).getId()
    ) and
    
    // 检查 **kwargs 参数是否匹配
    (
      // 情况1: lambda 和函数调用都没有 **kwargs
      not exists(lambdaFunc.getKwarg()) and not exists(funcCall.getKwargs())
      or
      // 情况2: lambda 和函数调用的 **kwargs 名称相同
      lambdaFunc.getKwarg().(Name).getId() = funcCall.getKwargs().(Name).getId()
    ) and
    
    // 检查 *args 参数是否匹配
    (
      // 情况1: lambda 和函数调用都没有 *args
      not exists(lambdaFunc.getVararg()) and not exists(funcCall.getStarargs())
      or
      // 情况2: lambda 和函数调用的 *args 名称相同
      lambdaFunc.getVararg().(Name).getId() = funcCall.getStarargs().(Name).getId()
    ) and
    
    // 确保函数调用中没有使用命名参数
    not exists(funcCall.getAKeyword())
  ) and
  
  // 如果 lambda 有默认参数值，则不能直接替换为被调用函数
  not exists(lambdaExpr.getArgs().getADefault())
}

/**
 * 检查一个 lambda 表达式是否是不必要的，
 * 即它包装了一个在 lambda 创建时和执行时都指向同一对象的表达式。
 */
predicate unnecessary_lambda(Lambda lambdaExpr, Expr wrappedExpr) {
  // 首先检查 lambda 是否是一个简单的包装器
  simple_wrapper(lambdaExpr, wrappedExpr) and
  
  // 然后检查被包装的表达式在 lambda 创建时和执行时是否指向同一对象
  (
    // 情况1: 包装了一个普通类
    exists(ClassValue classObj | wrappedExpr.pointsTo(classObj))
    or
    // 情况2: 包装了一个普通函数
    exists(FunctionValue funcObj | wrappedExpr.pointsTo(funcObj))
    or
    // 情况3: 包装了封闭实例的绑定方法
    exists(ClassValue enclosingClass, Attribute methodAttr | 
      enclosingClass.getScope() = lambdaExpr.getScope().getScope() and 
      methodAttr = wrappedExpr |
      
      // 检查方法的对象是 self
      methodAttr.getObject().(Name).getId() = "self" and
      
      // 检查类具有该属性
      enclosingClass.hasAttribute(methodAttr.getName())
    )
  )
}

from Lambda lambdaExpr, Expr wrappedExpr
where unnecessary_lambda(lambdaExpr, wrappedExpr)
select lambdaExpr,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."