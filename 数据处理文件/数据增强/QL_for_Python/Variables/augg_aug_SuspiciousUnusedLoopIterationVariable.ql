/**
 * @name Suspicious unused loop iteration variable
 * @description A loop iteration variable is unused, which suggests an error.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/unused-loop-variable
 */

import python

/**
 * 判断给定语句是否为变量递增操作，支持两种形式：x += n 或 x = x + n
 * @param stmtToCheck 待检查的语句
 */
predicate is_increment_operation(Stmt stmtToCheck) {
  /* 情况1: 增量赋值形式，如 x += 1 */
  stmtToCheck.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* 情况2: 标准赋值形式，如 x = x + 1 */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = stmtToCheck.(AssignStmt).getTarget(0) and
    addExpr = stmtToCheck.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * 判断给定的 for 循环是否为计数循环（即每次迭代变量递增）
 * @param forLoop 待检查的 for 循环
 */
predicate is_counting_loop(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * 判断给定的 for 循环是否为空循环（仅包含 Pass 语句）
 * @param forLoop 待检查的 for 循环
 */
predicate is_empty_loop(For forLoop) { 
  not exists(forLoop.getStmt(1)) and 
  forLoop.getStmt(0) instanceof Pass 
}

/**
 * 判断给定的 for 循环是否只包含一个返回或中断语句
 * @param forLoop 待检查的 for 循环
 */
predicate has_single_exit_statement(For forLoop) {
  not exists(Continue c | forLoop.contains(c)) and
  exists(Stmt lastStmt | lastStmt = forLoop.getBody().getLastItem() |
    lastStmt instanceof Return
    or
    lastStmt instanceof Break
  )
}

/**
 * 判断控制流节点是否指向对 range 或 xrange 的调用
 * @param flowNode 待检查的控制流节点
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* 处理直接调用 range/xrange 的情况（Python 2 中为函数，Python 3 中为类） */
  exists(Value rangeValue |
    rangeValue = Value::named("range") or
    rangeValue = Value::named("xrange")
  |
    flowNode = rangeValue.getACall()
  )
  or
  /* 处理指针分析失败的情况，如 'from six.moves import range' */
  exists(string rangeFuncName | flowNode.getNode().(Call).getFunc().(Name).getId() = rangeFuncName |
    rangeFuncName = "range" or rangeFuncName = "xrange"
  )
  or
  /* 处理嵌套调用情况，如 list(range(...)) 或 list(list(range(...))) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * 判断名称节点是否使用了非常量变量
 * @param varNameNode 待检查的名称节点
 */
predicate uses_non_constant_variable(Name varNameNode) {
  exists(Variable targetVar |
    varNameNode.uses(targetVar) and
    /* 使用是局部的 */
    not varNameNode.getScope() instanceof Module and
    /* 变量不是全局的 */
    not targetVar.getScope() instanceof Module
  |
    /* 变量被多次定义（动态的） */
    strictcount(Name def | def.defines(targetVar)) > 1
    or
    /* 变量在 for 循环中被定义 */
    exists(For forLoop, Name def | forLoop.contains(def) and def.defines(targetVar))
    or
    /* 变量在 while 循环中被定义 */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(targetVar))
  )
}

/**
 * 判断循环体是否隐式地重复了某些操作 N 次
 * 例如：queue.add(None)
 * @param forLoop 待检查的 for 循环
 */
predicate is_implicit_repetition(For forLoop) {
  /* 循环体只有一个语句 */
  not exists(forLoop.getStmt(1)) and
  /* 该语句包含不可变字面量 */
  exists(ImmutableLiteral immutableLiteral | forLoop.getStmt(0).contains(immutableLiteral)) and
  /* 不包含使用非常量变量的名称 */
  not exists(Name varNameNode | forLoop.getBody().contains(varNameNode) and uses_non_constant_variable(varNameNode))
}

/**
 * 获取与推导式中的 for 语句相关的可迭代对象的控制流图节点
 * for 语句是推导式中的人工 for 语句
 * 结果是该推导式中的可迭代对象
 * 例如：从 `{ y for y in x }` 中获取 `x`
 * @param comprehensionFor 推导式中的 for 语句
 * @return 可迭代对象的控制流图节点
 */
ControlFlowNode get_comprehension_iterable(For comprehensionFor) {
  exists(Comp comprehensionExpr | 
    comprehensionExpr.getFunction().getStmt(0) = comprehensionFor | 
    comprehensionExpr.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * 判断变量名是否适合作为未使用变量（以下划线开头）
 * @param targetVar 待检查的变量
 */
predicate name_acceptable_for_unused_variable(Variable targetVar) {
  exists(string name | name = targetVar.getId() and name.matches("_%"))
}

/**
 * 查找未使用的循环迭代变量，并生成相应的警告信息
 */
from For forLoop, Variable loopVar, string alertMessage
where
  /* 循环目标变量是 loopVar */
  forLoop.getTarget() = loopVar.getAnAccess() and
  /* 循环增量语句中不包含 loopVar */
  not forLoop.getAStmt().contains(loopVar.getAnAccess()) and
  /* 循环迭代器不是对 range 或 xrange 的调用 */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* 推导式中的迭代器也不是对 range 或 xrange 的调用 */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* loopVar 的名称不适合作为未使用变量 */
  not name_acceptable_for_unused_variable(loopVar) and
  /* 不在生成器表达式中 */
  not forLoop.getScope().getName() = "genexpr" and
  /* 不是空循环 */
  not is_empty_loop(forLoop) and
  /* 不只包含一个返回或中断语句 */
  not has_single_exit_statement(forLoop) and
  /* 不是计数循环 */
  not is_counting_loop(forLoop) and
  /* 不是隐式重复操作 */
  not is_implicit_repetition(forLoop) and
  /* 根据变量是否在循环体内被删除，设置不同的警告消息 */
  if exists(Name deletionNode | deletionNode.deletes(loopVar) and forLoop.getAStmt().contains(deletionNode))
  then alertMessage = "' is deleted, but not used, in the loop body."
  else alertMessage = "' is not used in the loop body."
select forLoop, "For loop variable '" + loopVar.getId() + alertMessage