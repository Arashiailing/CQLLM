/**
 * @name Dead code detection
 * @description Identifies code that cannot be executed
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

// 检查导入语句是否用于类型提示
// 这类导入语句通常不应标记为不可达代码
predicate is_typing_related_import(ImportingStmt importedStmt) {
  exists(Module modScope |
    importedStmt.getScope() = modScope and
    exists(TypeHintComment typeHintComment | typeHintComment.getLocation().getFile() = modScope.getFile())
  )
}

// 检查语句是否包含函数中唯一的yield表达式
// 这样的代码块可能是故意设计的生成器函数
predicate contains_unique_yield_in_function(Stmt stmtWithYield) {
  exists(Yield yieldNode | stmtWithYield.contains(yieldNode)) and
  exists(Function funcScope |
    funcScope = stmtWithYield.getScope() and
    strictcount(Yield yieldNode | funcScope.containsInScope(yieldNode)) = 1
  )
}

// 检查语句是否与contextlib.suppress处于同一作用域
// 使用contextlib.suppress的代码块可能有意捕获异常，导致某些代码看起来不可达
predicate shares_scope_with_suppression(Stmt stmtInScope) {
  exists(With suppressWithStmt |
    suppressWithStmt.getContextExpr().(Call).getFunc().pointsTo(Value::named("contextlib.suppress")) and
    suppressWithStmt.getScope() = stmtInScope.getScope()
  )
}

// 检查语句是否用于标记不可能执行的else分支
// 在if-elif-else链末尾抛出异常的语句可能是防御性编程的一部分
predicate marks_impossible_else_branch(Stmt stmtInElse) {
  exists(If ifBlock | ifBlock.getOrelse().getItem(0) = stmtInElse |
    stmtInElse.(Assert).getTest() instanceof False
    or
    stmtInElse instanceof Raise
  )
}

// 确定语句是否应被报告为不可达代码
// 综合多种条件，排除不应报告的不可达代码情况
predicate is_reportable_unreachable(Stmt unreachableStmt) {
  unreachableStmt.isUnreachable() and
  not is_typing_related_import(unreachableStmt) and
  not shares_scope_with_suppression(unreachableStmt) and
  not contains_unique_yield_in_function(unreachableStmt) and
  not marks_impossible_else_branch(unreachableStmt) and
  // 排除被其他不可达语句包含或在其他不可达语句之后的语句
  not exists(Stmt otherUnreachable | otherUnreachable.isUnreachable() |
    otherUnreachable.contains(unreachableStmt)
    or
    exists(StmtList statementList, int previousIndex, int currentIndex | 
      statementList.getItem(previousIndex) = otherUnreachable and 
      statementList.getItem(currentIndex) = unreachableStmt and 
      previousIndex < currentIndex
    )
  )
}

// 查询所有可报告的不可达代码
from Stmt unreachableStmt
where is_reportable_unreachable(unreachableStmt)
select unreachableStmt, "This statement is unreachable."