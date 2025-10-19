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
 * 检查给定语句是否为变量递增操作，例如 x += n 或 x = x + n
 * @param statement 待检查的语句
 */
predicate is_increment_operation(Stmt statement) {
  /* 情况1: x += n 形式的递增 */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* 情况2: x = x + n 形式的递增 */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = statement.(AssignStmt).getTarget(0) and
    addExpr = statement.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * 检查给定的 for 循环是否为计数循环，即每次迭代变量递增
 * @param loop 待检查的 for 循环
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * 检查给定的 for 循环是否为空循环，即循环体只有一个 Pass 语句
 * @param loop 待检查的 for 循环
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * 检查给定的 for 循环是否只包含一个返回或中断语句
 * @param loop 待检查的 for 循环
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
 * 检查控制流节点是否指向对 range 或 xrange 的调用
 * @param node 待检查的控制流节点
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* 在 Python 2 中 range/xrange 是函数，在 Python 3 中是类，因此需要作为普通对象处理 */
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
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * 检查名称 n 是否使用了非常量变量
 * @param nameNode 待检查的名称节点
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
    exists(For forLoop, Name def | forLoop.contains(def) and def.defines(var))
    or
    /* 变量在 while 循环中被定义 */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * 检查循环体是否隐式地重复了某些操作 N 次
 * 例如：queue.add(None)
 * @param loop 待检查的 for 循环
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
 * @param forStmt 推导式中的 for 语句
 * @return 可迭代对象的控制流图节点
 */
ControlFlowNode get_comprehension_iterable(For forStmt) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = forStmt | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * 检查变量名是否适合作为未使用变量（以下划线开头）
 * @param var 待检查的变量
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string name | name = var.getId() and name.matches("_%"))
}

/**
 * 查找未使用的循环迭代变量，并生成相应的警告信息
 */
from For loop, Variable loopVar, string warningMsg
where
  /* 循环目标变量是 loopVar */
  loop.getTarget() = loopVar.getAnAccess() and
  /* 循环增量语句中不包含 loopVar */
  not loop.getAStmt().contains(loopVar.getAnAccess()) and
  /* 循环迭代器不是对 range 或 xrange 的调用 */
  not is_range_function_call(loop.getIter().getAFlowNode()) and
  /* 推导式中的迭代器也不是对 range 或 xrange 的调用 */
  not is_range_function_call(get_comprehension_iterable(loop)) and
  /* loopVar 的名称不适合作为未使用变量 */
  not name_acceptable_for_unused_variable(loopVar) and
  /* 不在生成器表达式中 */
  not loop.getScope().getName() = "genexpr" and
  /* 不是空循环 */
  not is_empty_loop(loop) and
  /* 不只包含一个返回或中断语句 */
  not has_single_exit_statement(loop) and
  /* 不是计数循环 */
  not is_counting_loop(loop) and
  /* 不是隐式重复操作 */
  not is_implicit_repetition(loop) and
  /* 根据变量是否在循环体内被删除，设置不同的警告消息 */
  if exists(Name delNode | delNode.deletes(loopVar) and loop.getAStmt().contains(delNode))
  then warningMsg = "' is deleted, but not used, in the loop body."
  else warningMsg = "' is not used in the loop body."
select loop, "For loop variable '" + loopVar.getId() + warningMsg