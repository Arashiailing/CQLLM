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
 * 检查 lambda 表达式是否仅作为简单包装器存在，
 * 即它只包含一个返回语句，该语句调用另一个函数且参数完全透传。
 */
predicate simple_wrapper(Lambda lambdaExpr, Expr wrappedExpr) {
  exists(Function func, Call call | 
    func = lambdaExpr.getInnerScope() and 
    call = lambdaExpr.getExpression() |
    
    // 获取被调用的函数
    wrappedExpr = call.getFunc() and
    
    // 检查参数数量是否相同
    count(func.getAnArg()) = count(call.getAnArg()) and
    
    // 检查参数名称是否完全匹配
    forall(int argIndex | exists(func.getArg(argIndex)) | 
      func.getArgName(argIndex) = call.getArg(argIndex).(Name).getId()) and
    
    // 检查关键字参数是否匹配
    (
      // 情况1: 没有关键字参数
      not exists(func.getKwarg()) and not exists(call.getKwargs())
      or
      // 情况2: 关键字参数名称相同
      func.getKwarg().(Name).getId() = call.getKwargs().(Name).getId()
    ) and
    
    // 检查可变参数是否匹配
    (
      // 情况1: 没有可变参数
      not exists(func.getVararg()) and not exists(call.getStarargs())
      or
      // 情况2: 可变参数名称相同
      func.getVararg().(Name).getId() = call.getStarargs().(Name).getId()
    ) and
    
    // 确保调用中没有使用命名参数
    not exists(call.getAKeyword())
  ) and
  
  // 确保lambda没有默认参数值，否则可能不是直接替代品
  not exists(lambdaExpr.getArgs().getADefault())
}

/**
 * 检查lambda表达式是否是不必要的，
 * 即它包装的对象在lambda创建和执行时都指向相同的对象。
 */
predicate unnecessary_lambda(Lambda lambdaExpr, Expr targetExpr) {
  // 首先验证是否为简单包装器
  simple_wrapper(lambdaExpr, targetExpr) and
  
  // 然后验证目标表达式在不同上下文中指向相同的对象
  (
    // 情况1: 指向普通类对象
    exists(ClassValue clsValue | targetExpr.pointsTo(clsValue))
    or
    // 情况2: 指向普通函数对象
    exists(FunctionValue funcValue | targetExpr.pointsTo(funcValue))
    or
    // 情况3: 指向封闭实例的绑定方法
    exists(ClassValue clsValue, Attribute attr | 
      clsValue.getScope() = lambdaExpr.getScope().getScope() and 
      attr = targetExpr |
      
      // 绑定方法的对象是self
      attr.getObject().(Name).getId() = "self" and
      
      // 确保类具有该属性
      clsValue.hasAttribute(attr.getName())
    )
  )
}

from Lambda lambdaExpr, Expr targetExpr
where unnecessary_lambda(lambdaExpr, targetExpr)
select lambdaExpr,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly."