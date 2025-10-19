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
 * 检查给定节点是否位于循环结构内。
 * 循环结构包括 'while' 和 'for' 循环。
 */
predicate isWithinLoop(AstNode currentNode) {
  // 直接父节点是循环类型
  currentNode.getParentNode() instanceof While
  or
  currentNode.getParentNode() instanceof For
  or
  // 递归检查：如果存在一个父节点在循环内，且当前节点是其子节点
  exists(AstNode parentInLoop | 
    isWithinLoop(parentInLoop) and 
    currentNode = parentInLoop.getAChildNode()
  )
}

// 查找不必要的删除语句
from Delete deleteStmt, Expr targetExpr, Function containingFunction
where
  // 条件1：删除语句是函数的最后一条语句
  containingFunction.getLastStatement() = deleteStmt and
  // 条件2：删除语句的目标是指定的表达式
  targetExpr = deleteStmt.getATarget() and
  // 条件3：目标表达式在函数的作用域内
  containingFunction.containsInScope(targetExpr) and
  // 条件4：排除删除字典/列表元素的情况（如 del a[0]）
  not targetExpr instanceof Subscript and
  // 条件5：排除删除对象属性的情况（如 del a.b）
  not targetExpr instanceof Attribute and
  // 条件6：排除删除语句在循环内的情况
  not isWithinLoop(deleteStmt) and
  // 条件7：排除调用 sys.exc_info 的情况，因为需要显式删除以打破引用循环
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = containingFunction
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", targetExpr, targetExpr.toString(), containingFunction,
  containingFunction.getName()