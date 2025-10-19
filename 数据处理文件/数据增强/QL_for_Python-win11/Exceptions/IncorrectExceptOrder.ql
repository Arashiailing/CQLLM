/**
 * @name Unreachable 'except' block
 * @description Handling general exceptions before specific exceptions means that the specific
 *              handlers are never executed.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

// 定义一个谓词函数 incorrect_except_order，用于判断两个异常处理块的顺序是否正确。
predicate incorrect_except_order(ExceptStmt ex1, ClassValue cls1, ExceptStmt ex2, ClassValue cls2) {
  // 检查是否存在整数 i 和 j 以及 Try 语句 t，使得以下条件成立：
  exists(int i, int j, Try t |
    // ex1 是 t 的第 i 个异常处理块
    ex1 = t.getHandler(i) and
    // ex2 是 t 的第 j 个异常处理块
    ex2 = t.getHandler(j) and
    // i 小于 j，表示 ex1 在 ex2 之前
    i < j and
    // cls1 是 ex1 的异常类型
    cls1 = except_class(ex1) and
    // cls2 是 ex2 的异常类型
    cls2 = except_class(ex2) and
    // cls1 是 cls2 的父类或接口，即 ex1 处理的异常比 ex2 更一般
    cls1 = cls2.getASuperType()
  )
}

// 获取异常处理块 ex 对应的异常类型
ClassValue except_class(ExceptStmt ex) { ex.getType().pointsTo(result) }

// 从所有异常处理块 ex1、异常类型 cls1、异常处理块 ex2 和异常类型 cls2 中选择数据
from ExceptStmt ex1, ClassValue cls1, ExceptStmt ex2, ClassValue cls2
// 条件是这些数据满足 incorrect_except_order 谓词函数
where incorrect_except_order(ex1, cls1, ex2, cls2)
// 选择 ex2 作为结果，并生成一条警告信息
select ex2,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  cls2, cls2.getName(), ex1, "except block", cls1, cls1.getName()
