/**
 * @name Formatted object is not a mapping
 * @description The formatted object must be a mapping when the format includes a named specifier; otherwise a TypeError will be raised."
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/not-mapping
 */

import python  // 导入python模块，用于处理Python代码的查询
import semmle.python.strings  // 导入semmle.python.strings模块，用于字符串相关的操作

// 定义一个查询，查找格式字符串中包含命名规范符但右侧对象不是映射的情况
from Expr e, ClassValue t  // 从表达式e和类值t中选择数据
where
  exists(BinaryExpr b |  // 存在一个二元表达式b满足以下条件
    b.getOp() instanceof Mod and  // b的操作符是取模运算符（%）
    format_string(b.getLeft()) and  // b的左操作数是一个格式化字符串
    e = b.getRight() and  // e是b的右操作数
    mapping_format(b.getLeft()) and  // b的左操作数包含映射格式
    e.pointsTo().getClass() = t and  // e指向的对象的类是t
    not t.isMapping()  // t不是一个映射类型
  )
select e, "Right hand side of a % operator must be a mapping, not class $@.", t, t.getName()  // 选择e并报告错误信息，指出%操作符右侧必须是一个映射类型，而不是类t
