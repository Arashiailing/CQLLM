/**
 * @name Unreachable code
 * @description Code is unreachable
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-561
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-statement
 */

import python

// 判断导入语句是否与类型提示相关
// 类型提示相关的导入语句通常不应被视为不可达代码
predicate is_typing_related_import(ImportingStmt importStmt) {
  exists(Module moduleScope |
    importStmt.getScope() = moduleScope and // 确定导入语句的作用域
    exists(TypeHintComment typeHint | typeHint.getLocation().getFile() = moduleScope.getFile()) // 检查模块中是否存在类型提示注释
  )
}

// 判断语句是否包含函数作用域内唯一的yield表达式
// 包含唯一yield表达式的代码块可能是有意设计的生成器函数
predicate contains_unique_yield_in_function(Stmt targetStmt) {
  exists(Yield yieldExpr | targetStmt.contains(yieldExpr)) and // 检查目标语句中是否包含yield表达式
  exists(Function functionScope |
    functionScope = targetStmt.getScope() and // 获取目标语句的作用域函数
    strictcount(Yield yieldExpr | functionScope.containsInScope(yieldExpr)) = 1 // 确保函数作用域内只有一个yield表达式
  )
}

// 判断目标语句是否与contextlib.suppress在同一作用域中使用
// 使用contextlib.suppress的代码块可能有意捕获异常，使某些代码看似不可达
predicate shares_scope_with_suppression(Stmt targetStmt) {
  exists(With withStmt |
    withStmt.getContextExpr().(Call).getFunc().pointsTo(Value::named("contextlib.suppress")) and // 检查with语句是否使用contextlib.suppress
    withStmt.getScope() = targetStmt.getScope() // 确保with语句与目标语句在同一作用域
  )
}

// 判断语句是否标记了不可能的else分支
// 在if-elif-else链末尾引发异常的语句可能是有意设计的防御性编程
predicate marks_impossible_else_branch(Stmt targetStmt) {
  exists(If ifStmt | ifStmt.getOrelse().getItem(0) = targetStmt |
    targetStmt.(Assert).getTest() instanceof False // 检查是否为断言False的语句
    or
    targetStmt instanceof Raise // 检查是否为引发异常的语句
  )
}

// 判断语句是否为可报告的不可达代码
// 综合考虑多种情况，过滤掉不应报告的不可达代码
predicate is_reportable_unreachable(Stmt targetStmt) {
  targetStmt.isUnreachable() and // 基本条件：语句必须是不可达的
  not is_typing_related_import(targetStmt) and // 排除类型提示相关的导入语句
  not shares_scope_with_suppression(targetStmt) and // 排除与contextlib.suppress共享作用域的语句
  not contains_unique_yield_in_function(targetStmt) and // 排除包含唯一yield表达式的代码块
  not marks_impossible_else_branch(targetStmt) and // 排除标记不可能else分支的语句
  // 排除被其他不可达语句包含或在其他不可达语句之后的语句
  not exists(Stmt otherUnreachableStmt | otherUnreachableStmt.isUnreachable() |
    otherUnreachableStmt.contains(targetStmt) // 排除被其他不可达语句包含的语句
    or
    exists(StmtList stmtList, int prevIndex, int currentIndex | 
      stmtList.getItem(prevIndex) = otherUnreachableStmt and 
      stmtList.getItem(currentIndex) = targetStmt and 
      prevIndex < currentIndex // 排除在其他不可达语句之后的语句
    )
  )
}

// 查询所有可报告的不可达代码
from Stmt targetStmt
where is_reportable_unreachable(targetStmt)
select targetStmt, "This statement is unreachable."