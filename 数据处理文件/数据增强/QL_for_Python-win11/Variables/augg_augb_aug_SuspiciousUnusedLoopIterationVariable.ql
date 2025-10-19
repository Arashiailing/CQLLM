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
 * 检测给定语句是否为变量递增操作，如 x += n 或 x = x + n
 * @param statement 要分析的语句
 */
predicate is_increment_operation(Stmt statement) {
  /* 检测 x += n 形式的递增操作 */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* 检测 x = x + n 形式的递增操作 */
  exists(Name targetVar, BinaryExpr additionExpr |
    targetVar = statement.(AssignStmt).getTarget(0) and
    additionExpr = statement.(AssignStmt).getValue() and
    additionExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    additionExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * 确定给定的 for 循环是否为计数循环（每次迭代变量递增）
 * @param loop 要检查的 for 循环
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * 检查给定的 for 循环是否为空循环（循环体只有一个 Pass 语句）
 * @param loop 要检查的 for 循环
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * 判断给定的 for 循环是否只包含一个返回或中断语句
 * @param loop 要检查的 for 循环
 */
predicate has_single_exit_statement(For loop) {
  not exists(Continue c | loop.contains(c)) and
  exists(Stmt lastStmt | lastStmt = loop.getBody().getLastItem() |
    lastStmt instanceof Return
    or
    lastStmt instanceof Break
  )
}

/**
 * 判断控制流节点是否引用了 range 或 xrange 函数/类的调用
 * @param node 要检查的控制流节点
 */
predicate references_range_function(ControlFlowNode node) {
  /* 在 Python 2 中 range/xrange 是函数，在 Python 3 中是类，需要作为普通对象处理 */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or
    rangeFunc = Value::named("xrange")
  |
    node = rangeFunc.getACall()
  )
  or
  /* 处理 'from six.moves import range' 或类似情况导致的指针分析失败 */
  exists(string rangeName | node.getNode().(Call).getFunc().(Name).getId() = rangeName |
    rangeName = "range" or rangeName = "xrange"
  )
  or
  /* 处理 list(range(...)) 和 list(list(range(...))) 等嵌套调用 */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  references_range_function(node.(CallNode).getArg(0))
}

/**
 * 判断名称节点是否使用了非常量变量
 * @param nameNode 要检查的名称节点
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable var |
    nameNode.uses(var) and
    /* 使用是局部的 */
    not nameNode.getScope() instanceof Module and
    /* 变量不是全局的 */
    not var.getScope() instanceof Module
  |
    /* 变量被多次定义（动态的） */
    strictcount(Name def | def.defines(var)) > 1
    or
    /* 变量在 for 循环中被定义 */
    exists(For loop, Name def | loop.contains(def) and def.defines(var))
    or
    /* 变量在 while 循环中被定义 */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * 判断循环体是否隐式地重复了某些操作 N 次
 * 例如：queue.add(None)
 * @param loop 要检查的 for 循环
 */
predicate is_implicit_repetition(For loop) {
  /* 循环体只有一个语句 */
  not exists(loop.getStmt(1)) and
  /* 该语句包含不可变字面量 */
  exists(ImmutableLiteral immLiteral | loop.getStmt(0).contains(immLiteral)) and
  /* 不包含使用非常量变量的名称 */
  not exists(Name nameNode | loop.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * 获取与推导式中的 for 语句相关的可迭代对象的控制流图节点
 * for 语句 `f` 是推导式中的人工 for 语句
 * 结果是该推导式中的可迭代对象
 * 例如：从 `{ y for y in x }` 中获取 `x`
 * @param comprehensionFor 推导式中的 for 语句
 * @return 可迭代对象的控制流节点
 */
ControlFlowNode get_comprehension_iterable(For comprehensionFor) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = comprehensionFor | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * 判断变量名是否适合作为未使用变量（以下划线开头）
 * @param variable 要检查的变量
 */
predicate is_unused_variable_name_convention(Variable variable) {
  exists(string name | name = variable.getId() and name.matches("_%"))
}

/**
 * 查找未使用的循环迭代变量，并生成相应的警告信息
 */
from For forLoop, Variable iterationVar, string warningMessage
where
  /* 循环目标变量是 iterationVar */
  forLoop.getTarget() = iterationVar.getAnAccess() and
  /* 循环增量语句中不包含 iterationVar */
  not forLoop.getAStmt().contains(iterationVar.getAnAccess()) and
  /* 循环迭代器不是对 range 或 xrange 的调用 */
  not references_range_function(forLoop.getIter().getAFlowNode()) and
  /* 推导式中的迭代器也不是对 range 或 xrange 的调用 */
  not references_range_function(get_comprehension_iterable(forLoop)) and
  /* iterationVar 的名称不适合作为未使用变量 */
  not is_unused_variable_name_convention(iterationVar) and
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
  if exists(Name delNode | delNode.deletes(iterationVar) and forLoop.getAStmt().contains(delNode))
  then warningMessage = "' is deleted, but not used, in the loop body."
  else warningMessage = "' is not used in the loop body."
select forLoop, "For loop variable '" + iterationVar.getId() + warningMessage