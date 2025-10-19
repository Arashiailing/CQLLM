/**
 * @name Empty except
 * @description Except doesn't do anything and has no comment
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-390
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/empty-except
 */

import python
import semmle.python.ApiGraphs

// 定义一个谓词函数，用于判断except语句是否为空（即只包含pass语句）
predicate empty_except(ExceptStmt ex) {
  // 检查except块中是否存在非Pass的语句
  not exists(Stmt s | s = ex.getAStmt() and not s instanceof Pass)
}

// 定义一个谓词函数，用于判断except语句是否没有else部分
predicate no_else(ExceptStmt ex) { 
  // 检查except语句是否有else部分
  not exists(ex.getTry().getOrelse()) 
}

// 定义一个谓词函数，用于判断except语句是否没有注释
predicate no_comment(ExceptStmt ex) {
  // 检查except语句所在行及其范围内是否存在注释
  not exists(Comment c |
    c.getLocation().getFile() = ex.getLocation().getFile() and
    c.getLocation().getStartLine() >= ex.getLocation().getStartLine() and
    c.getLocation().getEndLine() <= ex.getBody().getLastItem().getLocation().getEndLine()
  )
}

// 定义一个谓词函数，用于判断except语句是否涉及非本地控制流
predicate non_local_control_flow(ExceptStmt ex) {
  // 检查except类型是否为StopIteration异常
  ex.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// 定义一个谓词函数，用于判断try语句块是否有正常出口
predicate try_has_normal_exit(Try try) {
  // 检查是否存在非异常的前驱和后继节点对
  exists(ControlFlowNode pred, ControlFlowNode succ |
    /* Exists a non-exception predecessor, successor pair */
    pred.getASuccessor() = succ and
    not pred.getAnExceptionalSuccessor() = succ
  |
    /* Successor is either a normal flow node or a fall-through exit */
    not exists(Scope s | s.getReturnNode() = succ) and
    /* Predecessor is in try body and successor is not */
    pred.getNode().getParentNode*() = try.getAStmt() and
    not succ.getNode().getParentNode*() = try.getAStmt()
  )
}

// 定义一个谓词函数，用于判断语句是否涉及属性访问
predicate attribute_access(Stmt s) {
  // 检查语句是否是属性访问表达式或调用了getattr、setattr、delattr函数
  s.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string name | s.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = name |
    name = "getattr" or name = "setattr" or name = "delattr"
  )
  or
  s.(Delete).getATarget() instanceof Attribute
}

// 定义一个谓词函数，用于判断语句是否涉及下标操作
predicate subscript(Stmt s) {
  // 检查语句是否是下标表达式或删除下标表达式
  s.(ExprStmt).getValue() instanceof Subscript
  or
  s.(Delete).getATarget() instanceof Subscript
}

// 定义一个谓词函数，用于判断语句是否涉及编码或解码操作
predicate encode_decode(Call ex, Expr type) {
  // 检查调用的函数名是否为encode或decode，并匹配相应的异常类型
  exists(string name | ex.getFunc().(Attribute).getName() = name |
    name = "encode" and
    type = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr()
    or
    name = "decode" and
    type = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr()
  )
}

// 定义一个谓词函数，用于判断except处理器是否只处理特定类型的小范围异常
predicate small_handler(ExceptStmt ex, Stmt s, Expr type) {
  // 检查except处理器是否只有一个语句，并且该语句是特定类型的异常处理
  not exists(ex.getTry().getStmt(1)) and
  s = ex.getTry().getStmt(0) and
  ex.getType() = type
}

// 定义一个谓词函数，用于判断except处理器是否专注于处理特定类型的异常
predicate focussed_handler(ExceptStmt ex) {
  // 检查except处理器是否专注于处理IndexError、AttributeError、NameError或编码解码相关的异常
  exists(Stmt s, Expr type | small_handler(ex, s, type) |
    subscript(s) and
    type = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    attribute_access(s) and
    type = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    s.(ExprStmt).getValue() instanceof Name and
    type = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    encode_decode(s.(ExprStmt).getValue(), type)
  )
}

// 定义一个查询，选择满足条件的except语句并报告问题
from ExceptStmt ex
where
  // 检查except语句是否为空且没有else部分和注释，不涉及非本地控制流，不是try-return语句，有正常出口，并且不是专注的处理器
  empty_except(ex) and
  no_else(ex) and
  no_comment(ex) and
  not non_local_control_flow(ex) and
  not ex.getTry() = try_return() and
  try_has_normal_exit(ex.getTry()) and
  not focussed_handler(ex)
select ex, "'except' clause does nothing but pass and there is no explanatory comment."
