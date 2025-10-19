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
predicate is_typing_related_import(ImportingStmt importDecl) {
  exists(Module mod |
    importDecl.getScope() = mod and // 验证导入声明的作用域为模块
    exists(TypeHintComment typeHint | typeHint.getLocation().getFile() = mod.getFile()) // 检查模块是否包含类型提示注释
  )
}

// 检查语句是否包含作用域内唯一的yield表达式
predicate contains_unique_yield(Stmt stmt) {
  exists(Yield yieldExpr | stmt.contains(yieldExpr)) and // 确认语句包含yield表达式
  exists(Function enclosingFunc |
    enclosingFunc = stmt.getScope() and // 获取语句所在函数作用域
    strictcount(Yield y | enclosingFunc.containsInScope(y)) = 1 // 验证函数作用域内仅有一个yield表达式
  )
}

// 检查语句作用域中是否存在contextlib.suppress的使用
predicate has_suppression_in_scope(Stmt stmt) {
  exists(With withBlock |
    withBlock.getContextExpr().(Call).getFunc().pointsTo(Value::named("contextlib.suppress")) and // 确认with语句使用contextlib.suppress
    withBlock.getScope() = stmt.getScope() // 验证作用域一致性
  )
}

// 检查语句是否标记不可能的else分支（通过断言或异常）
predicate marks_impossible_else_branch(Stmt stmt) {
  exists(If ifBlock | ifBlock.getOrelse().getItem(0) = stmt |
    stmt.(Assert).getTest() instanceof False // 识别断言False的情况
    or
    stmt instanceof Raise // 识别异常抛出语句
  )
}

// 判断语句是否为可报告的不可达代码
predicate is_reportable_unreachable(Stmt stmt) {
  // 基础条件：语句不可达
  stmt.isUnreachable() and
  
  // 排除特定情况：类型提示导入
  not is_typing_related_import(stmt) and
  
  // 排除特定情况：suppress作用域内的语句
  not has_suppression_in_scope(stmt) and
  
  // 排除嵌套不可达代码情况
  not exists(Stmt otherUnreachable | otherUnreachable.isUnreachable() |
    otherUnreachable.contains(stmt) or // 被其他不可达语句包含
    exists(StmtList stmtList, int prevIdx, int currIdx | 
      stmtList.getItem(prevIdx) = otherUnreachable and 
      stmtList.getItem(currIdx) = stmt and 
      prevIdx < currIdx // 位于其他不可达语句之后
    )
  ) and
  
  // 排除唯一yield语句情况
  not contains_unique_yield(stmt) and
  
  // 排除不可能else分支标记
  not marks_impossible_else_branch(stmt)
}

// 查询可报告的不可达代码
from Stmt unreachableStmt
where is_reportable_unreachable(unreachableStmt)
select unreachableStmt, "This statement is unreachable."