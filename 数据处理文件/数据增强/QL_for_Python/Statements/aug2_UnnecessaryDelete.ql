/**
 * @name Unnecessary delete statement in function
 * @description Using a 'delete' statement to delete a local variable is
 *              unnecessary, because the variable is deleted automatically when
 *              the function exits.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

/**
 * 判断给定的AST节点是否位于循环结构内部。
 * 递归检查节点的父节点是否为While或For循环，或者节点是否为循环内节点的子节点。
 */
predicate isInsideLoop(AstNode currentNode) {
  // 基本情况：节点的直接父节点是循环结构
  currentNode.getParentNode() instanceof While
  or
  currentNode.getParentNode() instanceof For
  or
  // 递归情况：节点是某个在循环内的节点的子节点
  exists(AstNode parentInLoop | 
    isInsideLoop(parentInLoop) and 
    currentNode = parentInLoop.getAChildNode()
  )
}

// 查找函数中不必要的删除语句
from Delete deleteStmt, Expr targetExpr, Function containingFunc
where
  // 条件1: 删除语句是函数的最后一个语句
  containingFunc.getLastStatement() = deleteStmt and
  // 条件2: 删除语句的目标是表达式targetExpr
  targetExpr = deleteStmt.getATarget() and
  // 条件3: 目标表达式在函数的作用域内
  containingFunc.containsInScope(targetExpr) and
  // 条件4: 排除特定类型的删除目标
  (
    not targetExpr instanceof Subscript and
    not targetExpr instanceof Attribute
  ) and
  // 条件5: 删除语句不在循环内
  not isInsideLoop(deleteStmt) and
  // 条件6: 排除调用sys.exc_info的情况，因为这种情况下需要显式删除以打破引用循环
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = containingFunc
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", targetExpr, targetExpr.toString(), containingFunc,
  containingFunc.getName()