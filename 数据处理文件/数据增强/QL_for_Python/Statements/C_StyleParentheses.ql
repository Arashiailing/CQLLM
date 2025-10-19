/**
 * @name C-style condition
 * @description Putting parentheses around a condition in an 'if' or 'while' statement is
 *              unnecessary and harder to read.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/c-style-parentheses
 */

import python  // 导入Python语言库，用于分析Python代码

from Expr e, Location l, string kind, string what  // 从表达式、位置、字符串类型和描述中选择数据
where
  e.isParenthesized() and  // 检查表达式是否被括号包围
  not e instanceof Tuple and  // 确保表达式不是元组实例
  (
    exists(If i | i.getTest() = e) and kind = "if" and what = "condition"  // 如果表达式是if语句的条件
    or
    exists(While w | w.getTest() = e) and kind = "while" and what = "condition"  // 如果表达式是while语句的条件
    or
    exists(Return r | r.getValue() = e) and kind = "return" and what = "value"  // 如果表达式是return语句的值
    or
    exists(Assert a | a.getTest() = e and not exists(a.getMsg())) and  // 如果表达式是assert语句的测试部分且没有消息
    kind = "assert" and
    what = "test"
  ) and
  // These require parentheses  // 以下情况需要括号
  (not e instanceof Yield and not e instanceof YieldFrom and not e instanceof GeneratorExp) and  // 确保表达式不是Yield、YieldFrom或GeneratorExp实例
  l = e.getLocation() and  // 获取表达式的位置
  l.getStartLine() = l.getEndLine()  // 确保表达式在同一行内
select e, "Parenthesized " + what + " in '" + kind + "' statement."  // 选择表达式并生成描述信息
