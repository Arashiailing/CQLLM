/**
 * @name Constant in conditional expression or statement
 * @description The conditional is always true or always false
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-561
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/constant-conditional-expression
 */

import python

// 定义一个谓词函数，用于判断表达式是否是条件语句中的测试条件
predicate is_condition(Expr cond) {
  // 如果存在一个If语句，其测试条件等于cond，或者存在一个IfExp语句，其测试条件等于cond，则返回true
  exists(If i | i.getTest() = cond) or
  exists(IfExp ie | ie.getTest() = cond)
}

/* Treat certain unmodified builtins as constants as well. */
// 定义一个谓词函数，用于判断名称是否为某些特定的内置常量
predicate effective_constant(Name cond) {
  // 如果存在一个全局变量var，其名称等于cond的变量名，并且没有其他名称节点定义该变量，且变量名为"True", "False"或"NotImplemented"，则返回true
  exists(GlobalVariable var | var = cond.getVariable() and not exists(NameNode f | f.defines(var)) |
    var.getId() = "True" or var.getId() = "False" or var.getId() = "NotImplemented"
  )
}

// 定义一个谓词函数，用于判断测试条件是否使代码不可达
predicate test_makes_code_unreachable(Expr cond) {
  // 如果存在一个If语句，其测试条件等于cond，并且其第一个子语句或else分支是不可达的，或者存在一个While循环，其测试条件等于cond，并且其第一个子语句是不可达的，则返回true
  exists(If i | i.getTest() = cond | i.getStmt(0).isUnreachable() or i.getOrelse(0).isUnreachable())
  or
  exists(While w | w.getTest() = cond and w.getStmt(0).isUnreachable())
}

// 从所有表达式中选择满足以下条件的表达式cond
from Expr cond
where
  // cond是条件语句中的测试条件
  is_condition(cond) and
  // cond是一个常量或者是某些特定的内置常量
  (cond.isConstant() or effective_constant(cond)) and
  /* Ignore cases where test makes code unreachable, as that is handled in different query */
  // 忽略那些使代码不可达的测试条件，因为这将由不同的查询处理
  not test_makes_code_unreachable(cond)
// 选择cond并报告“测试一个常量将始终得到相同的结果”
select cond, "Testing a constant will always give the same result."
