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

/* f consists of a single return statement, whose value is a call. The arguments of the call are exactly the parameters of f */
predicate simple_wrapper(Lambda l, Expr wrapped) {
  exists(Function f, Call c | f = l.getInnerScope() and c = l.getExpression() |
    wrapped = c.getFunc() and // 获取调用的函数
    count(f.getAnArg()) = count(c.getAnArg()) and // 参数数量相同
    forall(int arg | exists(f.getArg(arg)) | f.getArgName(arg) = c.getArg(arg).(Name).getId()) and // 参数名称相同
    /* Either no **kwargs or they must match */
    (
      not exists(f.getKwarg()) and not exists(c.getKwargs()) // 没有关键字参数
      or
      f.getKwarg().(Name).getId() = c.getKwargs().(Name).getId() // 关键字参数匹配
    ) and
    /* Either no *args or they must match */
    (
      not exists(f.getVararg()) and not exists(c.getStarargs()) // 没有可变参数
      or
      f.getVararg().(Name).getId() = c.getStarargs().(Name).getId() // 可变参数匹配
    ) and
    /* No named parameters in call */
    not exists(c.getAKeyword()) // 调用中没有命名参数
  ) and
  // f is not necessarily a drop-in replacement for the lambda if there are default argument values
  not exists(l.getArgs().getADefault()) // 没有默认参数值
}

/* The expression called will refer to the same object if evaluated when the lambda is created or when the lambda is executed. */
predicate unnecessary_lambda(Lambda l, Expr e) {
  simple_wrapper(l, e) and // 检查是否为简单包装器
  (
    /* plain class */
    exists(ClassValue c | e.pointsTo(c)) // 指向类对象
    or
    /* plain function */
    exists(FunctionValue f | e.pointsTo(f)) // 指向函数对象
    or
    /* bound-method of enclosing instance */
    exists(ClassValue cls, Attribute a | cls.getScope() = l.getScope().getScope() and a = e |
      a.getObject().(Name).getId() = "self" and // 绑定方法的对象是自身
      cls.hasAttribute(a.getName()) // 类有该属性
    )
  )
}

from Lambda l, Expr e
where unnecessary_lambda(l, e) // 查询不必要的lambda表达式
select l,
  "This 'lambda' is just a simple wrapper around a callable object. Use that object directly." // 提示信息
