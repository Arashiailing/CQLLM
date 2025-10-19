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

// 定义一个谓词函数，用于判断节点是否在循环内
predicate isInsideLoop(AstNode node) {
  // 如果节点的父节点是While或For类型，则返回true
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  // 如果存在一个前驱节点，该前驱节点在循环内且当前节点是其子节点，则返回true
  or
  exists(AstNode prev | isInsideLoop(prev) | node = prev.getAChildNode())
}

// 从Delete语句、表达式和函数中进行查询
from Delete del, Expr e, Function f
where
  // 函数的最后一个语句是delete语句
  f.getLastStatement() = del and
  // delete语句的目标是表达式e
  e = del.getATarget() and
  // 表达式e在函数f的作用域内
  f.containsInScope(e) and
  // 排除目标是Subscript类型的情况
  not e instanceof Subscript and
  // 排除目标是Attribute类型的情况
  not e instanceof Attribute and
  // 排除delete语句在循环内的情况
  not isInsideLoop(del) and
  // 排除调用sys.exc_info的情况，因为这种情况下需要显式删除以打破引用循环
  not exists(FunctionValue ex |
    ex = Value::named("sys.exc_info") and
    ex.getACall().getScope() = f
  )
select del, "Unnecessary deletion of local variable $@ in function $@.", e, e.toString(), f,
  f.getName()
