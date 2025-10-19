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

// 检查导入语句是否用于类型提示
predicate is_typing_import(ImportingStmt importDecl) {
  exists(Module mod |
    importDecl.getScope() = mod and
    exists(TypeHintComment hint | hint.getLocation().getFile() = mod.getFile())
  )
}

// 检查语句是否包含函数作用域内唯一的yield表达式
predicate has_unique_yield(Stmt targetStmt) {
  exists(Yield yieldExpr | targetStmt.contains(yieldExpr)) and
  exists(Function func |
    func = targetStmt.getScope() and
    strictcount(Yield y | func.containsInScope(y)) = 1
  )
}

// 检查语句是否与contextlib.suppress在同一作用域中使用
predicate uses_suppression_context(Stmt targetStmt) {
  exists(With withBlock |
    withBlock.getContextExpr().(Call).getFunc().pointsTo(Value::named("contextlib.suppress")) and
    withBlock.getScope() = targetStmt.getScope()
  )
}

// 检查语句是否在if-elif-else链末尾触发异常
predicate terminates_impossible_branch(Stmt targetStmt) {
  exists(If ifBlock | ifBlock.getOrelse().getItem(0) = targetStmt |
    targetStmt.(Assert).getTest() instanceof False or
    targetStmt instanceof Raise
  )
}

// 判断语句是否为可报告的不可达代码
predicate is_reportable_unreachable(Stmt targetStmt) {
  targetStmt.isUnreachable() and
  not is_typing_import(targetStmt) and
  not uses_suppression_context(targetStmt) and
  not exists(Stmt otherUnreachable | otherUnreachable.isUnreachable() |
    otherUnreachable.contains(targetStmt) or
    exists(StmtList stmtList, int idx1, int idx2 | 
      stmtList.getItem(idx1) = otherUnreachable and 
      stmtList.getItem(idx2) = targetStmt and 
      idx1 < idx2
    )
  ) and
  not has_unique_yield(targetStmt) and
  not terminates_impossible_branch(targetStmt)
}

// 查询不可达代码并选择相应的语句和描述信息
from Stmt targetStmt
where is_reportable_unreachable(targetStmt)
select targetStmt, "This statement is unreachable."