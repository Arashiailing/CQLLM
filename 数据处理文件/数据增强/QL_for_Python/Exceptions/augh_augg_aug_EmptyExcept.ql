/**
 * @name Empty except
 * @description Identifies except clauses that contain only pass statements without explanatory comments
 * @kind problem
 * @tags reliability
 *       maintainability
 * @external/cwe/cwe-390
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/empty-except
 */

import python
import semmle.python.ApiGraphs

// 检查异常处理块是否仅包含 pass 语句
predicate isExceptBlockEmpty(ExceptStmt handler) {
  // 确保异常处理程序中没有非 pass 语句
  not exists(Stmt statement | 
    statement = handler.getAStmt() and 
    not statement instanceof Pass
  )
}

// 检查 try 语句是否没有 else 子句
predicate hasNoElseClause(ExceptStmt handler) { 
  // 确认 try 语句不存在 else 块
  not exists(handler.getTry().getOrelse()) 
}

// 检查异常处理程序是否缺少注释
predicate lacksComment(ExceptStmt handler) {
  // 验证异常处理块范围内没有注释
  not exists(Comment cmt |
    cmt.getLocation().getFile() = handler.getLocation().getFile() and
    cmt.getLocation().getStartLine() >= handler.getLocation().getStartLine() and
    cmt.getLocation().getEndLine() <= handler.getBody().getLastItem().getLocation().getEndLine()
  )
}

// 识别处理非本地控制流异常的处理器
predicate catchesNonLocalControlFlow(ExceptStmt handler) {
  // 检查是否处理 StopIteration 异常
  handler.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// 验证 try 块中存在正常执行路径
predicate containsNormalExecutionPath(Try tryStatement) {
  // 查找非异常控制流转换
  exists(ControlFlowNode predecessor, ControlFlowNode successor |
    /* 存在有效的非异常边 */
    predecessor.getASuccessor() = successor and
    not predecessor.getAnExceptionalSuccessor() = successor
  |
    /* 后继节点不是返回节点 */
    not exists(Scope s | s.getReturnNode() = successor) and
    /* 前驱节点在 try 块内，后继节点在 try 块外 */
    predecessor.getNode().getParentNode*() = tryStatement.getAStmt() and
    not successor.getNode().getParentNode*() = tryStatement.getAStmt()
  )
}

// 检测语句是否涉及属性访问
predicate usesAttributeAccess(Stmt statement) {
  // 表达式语句中的属性访问
  statement.(ExprStmt).getValue() instanceof Attribute
  or
  // 通过内置函数的属性访问
  exists(string funcName | 
    statement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = funcName |
    funcName in ["getattr", "setattr", "delattr"]
  )
  or
  // 属性删除操作
  statement.(Delete).getATarget() instanceof Attribute
}

// 识别带有下标操作的语句
predicate usesSubscriptOperation(Stmt statement) {
  // 表达式中的下标访问
  statement.(ExprStmt).getValue() instanceof Subscript
  or
  // 下标删除操作
  statement.(Delete).getATarget() instanceof Subscript
}

// 检测特定异常的编码/解码操作
predicate isEncodingOrDecodingOperation(Call call, Expr exceptionType) {
  // 验证函数名称并匹配相应的异常类型
  exists(string operation | 
    call.getFunc().(Attribute).getName() = operation |
    (operation = "encode" and
     exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (operation = "decode" and
     exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// 识别特定类型的最小异常处理器
predicate isSimplifiedExceptionHandler(ExceptStmt handler, Stmt statement, Expr exceptionType) {
  // 单语句 try 块与特定异常类型
  not exists(handler.getTry().getStmt(1)) and
  statement = handler.getTry().getStmt(0) and
  handler.getType() = exceptionType
}

// 检测针对特定场景的专门异常处理器
predicate isSpecializedHandler(ExceptStmt handler) {
  // 检查有针对性的异常处理模式
  exists(Stmt statement, Expr exceptionType | 
    isSimplifiedExceptionHandler(handler, statement, exceptionType) |
    // 下标操作的 IndexError
    (usesSubscriptOperation(statement) and
     exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // 属性访问的 AttributeError
    (usesAttributeAccess(statement) and
     exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // 名称引用的 NameError
    (statement.(ExprStmt).getValue() instanceof Name and
     exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // 编码/解码错误
    isEncodingOrDecodingOperation(statement.(ExprStmt).getValue(), exceptionType)
  )
}

// 识别包含 return 语句的 try 块
predicate containsReturnStatement(Try tryStatement) {
  exists(Return retStmt | retStmt.getParentNode*() = tryStatement)
}

// 主查询：检测有问题的空 except 块
from ExceptStmt handler
where
  // 识别没有解释的空 except 块
  isExceptBlockEmpty(handler) and
  hasNoElseClause(handler) and
  lacksComment(handler) and
  // 排除非本地控制流处理器
  not catchesNonLocalControlFlow(handler) and
  // 排除 try-return 构造
  not containsReturnStatement(handler.getTry()) and
  // 验证存在正常执行路径
  containsNormalExecutionPath(handler.getTry()) and
  // 排除专门的异常处理器
  not isSpecializedHandler(handler)
select handler, "'except' clause does nothing but pass and there is no explanatory comment."