/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind problem
 * @id py/error
 * @problem.severity error
 * @precision high
 * @security-severity 7.5
 * @tags maintainability
 *       reliability
 *       experimental
 */

// 导入Python库，用于分析Python代码
import python

// 定义查询谓词，查找不可达代码问题
predicate reportable_unreachable(Stmt s) {
  // 条件：存在一个表达式语句，其值等于s，并且没有其他表达式语句与s共享相同的值
  exists(ExprStmt e | e.getValue() = s | not exists(e2 | e2 != e | e2.getValue() = s))
}

// 查询不可达代码并选择相应的语句和描述信息
from Stmt s
where reportable_unreachable(s)
select s, "This statement is unreachable."