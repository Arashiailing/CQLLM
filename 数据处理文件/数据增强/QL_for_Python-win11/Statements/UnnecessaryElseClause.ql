/**
 * @name Unnecessary 'else' clause in loop
 * @description An 'else' clause in a 'for' or 'while' statement that does not contain a 'break' is redundant.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-else
 */

import python  # 导入python库，用于分析Python代码

from Stmt loop, StmtList body, StmtList clause, string kind  # 定义变量：loop表示循环语句，body表示循环体，clause表示else子句，kind表示循环类型（for或while）
where
  (
    exists(For f | f = loop | clause = f.getOrelse() and body = f.getBody() and kind = "for")  # 检查是否存在一个for循环，其else子句和循环体满足条件，且类型为"for"
    or
    exists(While w | w = loop | clause = w.getOrelse() and body = w.getBody() and kind = "while")  # 检查是否存在一个while循环，其else子句和循环体满足条件，且类型为"while"
  ) and
  not exists(Break b | body.contains(b))  # 检查循环体内是否不存在break语句
select loop,  # 选择符合条件的循环语句
  "This '" + kind + "' statement has a redundant 'else' as no 'break' is present in the body."  # 输出警告信息，指出该循环语句存在冗余的else子句，因为循环体内没有break语句
