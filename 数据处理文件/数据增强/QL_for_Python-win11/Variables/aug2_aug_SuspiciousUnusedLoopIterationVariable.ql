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
 * 判断给定语句是否为变量递增操作，例如 x += n 或 x = x + n
 * @param stmt 待检查的语句
 */
predicate is_increment_operation(Stmt stmt) {
  /* 检查 x += n 形式的递增操作 */
  stmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* 检查 x = x + n 形式的递增操作 */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = stmt.(AssignStmt).getTarget(0) and
    addExpr = stmt.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * 判断给定的 for 循环是否为计数循环，即每次迭代变量递增
 * @param forLoop 待检查的 for 循环
 */
predicate is_counting_loop(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * 判断给定的 for 循环是否为空循环，即循环体只有一个 Pass 语句
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
  exists(Stmt finalStmt | finalStmt = forLoop.getBody().getLastItem() |
    finalStmt instanceof Return
    or
    finalStmt instanceof Break
  )
}

/**
 * 判断控制流节点是否指向对 range 或 xrange 的调用
 * @param flowNode 待检查的控制流节点
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* 处理 Python 2/3 中的 range/xrange 函数调用 */
  exists(Value rangeValue |
    rangeValue = Value::named("range") or
    rangeValue = Value::named("xrange")
  |
    flowNode = rangeValue.getACall()
  )
  or
  /* 处理直接使用 range/xrange 名称的调用情况 */
  exists(string funcName | flowNode.getNode().(Call).getFunc().(Name).getId() = funcName |
    funcName = "range" or funcName = "xrange"
  )
  or
  /* 处理嵌套调用情况，如 list(range(...)) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * 判断名称节点是否使用了非常量变量
 * @param varName 待检查的名称节点
 */
predicate uses_non_constant_variable(Name varName) {
  exists(Variable variable |
    varName.uses(variable) and
    /* 确保使用是局部的 */
    not varName.getScope() instanceof Module and
    /* 确保变量不是全局的 */
    not variable.getScope() instanceof Module
  |
    /* 变量被多次定义（动态的） */
    strictcount(Name definition | definition.defines(variable)) > 1
    or
    /* 变量在 for 循环中被定义 */
    exists(For forLoop, Name definition | forLoop.contains(definition) and definition.defines(variable))
    or
    /* 变量在 while 循环中被定义 */
    exists(While whileLoop, Name definition | whileLoop.contains(definition) and definition.defines(variable))
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
  not exists(Name varName | forLoop.getBody().contains(varName) and uses_non_constant_variable(varName))
}

/**
 * 获取与推导式中的 for 语句相关的可迭代对象的控制流图节点
 * for 语句 `comprehensionFor` 是推导式中的人工 for 语句
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
 * @param variable 待检查的变量
 */
predicate name_acceptable_for_unused_variable(Variable variable) {
  exists(string varName | varName = variable.getId() and varName.matches("_%"))
}

/**
 * 查找未使用的循环迭代变量，并生成相应的警告信息
 */
from For forLoop, Variable iterationVar, string message
where
  /* 循环目标变量是 iterationVar */
  forLoop.getTarget() = iterationVar.getAnAccess() and
  /* 循环增量语句中不包含 iterationVar */
  not forLoop.getAStmt().contains(iterationVar.getAnAccess()) and
  /* 循环迭代器不是对 range 或 xrange 的调用 */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* 推导式中的迭代器也不是对 range 或 xrange 的调用 */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* iterationVar 的名称不适合作为未使用变量 */
  not name_acceptable_for_unused_variable(iterationVar) and
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
  if exists(Name deletionNode | deletionNode.deletes(iterationVar) and forLoop.getAStmt().contains(deletionNode))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
select forLoop, "For loop variable '" + iterationVar.getId() + message