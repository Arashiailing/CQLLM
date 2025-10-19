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

// 检测导入语句是否与类型提示相关联
// 此类导入通常不应被视为不可达代码，因为它们仅用于类型注解
predicate is_typing_related_import(ImportingStmt importNode) {
  exists(Module moduleScope |
    importNode.getScope() = moduleScope and // 确定导入语句所在的作用域
    exists(TypeHintComment typeHintComment | typeHintComment.getLocation().getFile() = moduleScope.getFile()) // 验证模块中是否存在类型提示注释
  )
}

// 检测语句是否包含函数作用域内唯一的yield表达式
// 此类代码块可能是有意设计的生成器函数，不应被标记为不可达
predicate contains_unique_yield_in_function(Stmt unreachableNode) {
  exists(Yield yieldNode | unreachableNode.contains(yieldNode)) and // 检查目标语句中是否包含yield表达式
  exists(Function funcScope |
    funcScope = unreachableNode.getScope() and // 获取目标语句所在的函数作用域
    strictcount(Yield yieldNode | funcScope.containsInScope(yieldNode)) = 1 // 确保函数作用域内只有一个yield表达式
  )
}

// 检测目标语句是否与contextlib.suppress在同一作用域中使用
// 使用contextlib.suppress的代码块可能有意捕获异常，使某些代码看似不可达
predicate shares_scope_with_suppression(Stmt unreachableNode) {
  exists(With withBlock |
    withBlock.getContextExpr().(Call).getFunc().pointsTo(Value::named("contextlib.suppress")) and // 检查with语句是否使用contextlib.suppress
    withBlock.getScope() = unreachableNode.getScope() // 确保with语句与目标语句在同一作用域
  )
}

// 检测语句是否标记了不可能的else分支
// 在if-elif-else链末尾引发异常的语句可能是有意设计的防御性编程
predicate marks_impossible_else_branch(Stmt unreachableNode) {
  exists(If ifBlock | ifBlock.getOrelse().getItem(0) = unreachableNode |
    unreachableNode.(Assert).getTest() instanceof False // 检查是否为断言False的语句
    or
    unreachableNode instanceof Raise // 检查是否为引发异常的语句
  )
}

// 综合判断语句是否为可报告的不可达代码
// 排除各种特殊情况，只报告真正的不可达代码
predicate is_reportable_unreachable(Stmt unreachableNode) {
  // 基本条件：语句必须是不可达的
  unreachableNode.isUnreachable() and
  
  // 排除特定类型的不可达代码
  not is_typing_related_import(unreachableNode) and // 排除类型提示相关的导入语句
  not shares_scope_with_suppression(unreachableNode) and // 排除与contextlib.suppress共享作用域的语句
  not contains_unique_yield_in_function(unreachableNode) and // 排除包含唯一yield表达式的代码块
  not marks_impossible_else_branch(unreachableNode) and // 排除标记不可能else分支的语句
  
  // 排除与其他不可达代码相关的语句
  not exists(Stmt anotherUnreachableNode | anotherUnreachableNode.isUnreachable() |
    anotherUnreachableNode.contains(unreachableNode) // 排除被其他不可达语句包含的语句
    or
    exists(StmtList statementList, int previousIndex, int currentPosition | 
      statementList.getItem(previousIndex) = anotherUnreachableNode and 
      statementList.getItem(currentPosition) = unreachableNode and 
      previousIndex < currentPosition // 排除在其他不可达语句之后的语句
    )
  )
}

// 查询所有可报告的不可达代码
from Stmt unreachableNode
where is_reportable_unreachable(unreachableNode)
select unreachableNode, "This statement is unreachable."