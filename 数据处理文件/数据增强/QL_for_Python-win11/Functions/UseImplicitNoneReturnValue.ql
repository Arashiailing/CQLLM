/**
 * @name Use of the return value of a procedure
 * @description The return value of a procedure (a function that does not return a value) is used. This is confusing to the reader as the value (None) has no meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/procedure-return-value-used
 */

import python
import Testing.Mox

// 定义一个谓词函数，用于判断一个调用表达式是否被使用
predicate is_used(Call c) {
  // 检查是否存在一个外部表达式，该表达式在作用域内包含当前调用，并且是调用、属性或下标操作之一
  exists(Expr outer | outer != c and outer.containsInScope(c) |
    outer instanceof Call or outer instanceof Attribute or outer instanceof Subscript
  )
  // 或者检查是否存在一个语句，该语句的子表达式是当前调用，并且不是表达式语句，且不是单个返回语句
  or
  exists(Stmt s |
    c = s.getASubExpression() and
    not s instanceof ExprStmt and
    /* Ignore if a single return, as def f(): return g() is quite common. Covers implicit return in a lambda. */
    not (s instanceof Return and strictcount(Return r | r.getScope() = s.getScope()) = 1)
  )
}

// 从调用表达式和函数值中选择数据
from Call c, FunctionValue func
where
  /* Call result is used, but callee is a procedure */
  is_used(c) and // 调用结果被使用，但被调用者是一个过程
  c.getFunc().pointsTo(func) and // 调用指向某个函数值
  func.getScope().isProcedure() and // 函数的作用域是一个过程
  /* All callees are procedures */
  forall(FunctionValue callee | c.getFunc().pointsTo(callee) | callee.getScope().isProcedure()) and // 所有被调用者都是过程
  /* Mox return objects have an `AndReturn` method */
  not useOfMoxInModule(c.getEnclosingModule()) // 排除使用Mox模块的情况
select c, "The result of $@ is used even though it is always None.", func, func.getQualifiedName() // 选择调用表达式，并报告其结果总是None的问题
