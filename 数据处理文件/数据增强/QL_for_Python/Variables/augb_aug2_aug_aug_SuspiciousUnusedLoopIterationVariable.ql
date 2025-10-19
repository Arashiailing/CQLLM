/**
 * @name 可疑的未使用循环迭代变量
 * @description 循环迭代变量未被使用，这可能是一个错误。
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
 * 判断语句是否表示变量自增操作（如 x += n 或 x = x + n）
 * @param stmt 待检查的语句
 */
predicate is_increment_operation(Stmt stmt) {
  /* 情况1：x += n 形式的自增 */
  stmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* 情况2：x = x + n 形式的自增 */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = stmt.(AssignStmt).getTarget(0) and
    addExpr = stmt.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * 判断 for 循环是否为计数循环（每次迭代中迭代变量都会自增）
 * @param loop 待检查的 for 循环
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * 判断 for 循环是否为空循环（仅包含 Pass 语句）
 * @param loop 待检查的 for 循环
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * 判断 for 循环是否仅包含单个退出语句（return 或 break）且无 continue
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
 * 判断控制流节点是否指向 range 或 xrange 函数调用
 * @param node 待检查的控制流节点
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* Python 2/3 兼容性处理：range/xrange 作为常规对象 */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or
    rangeFunc = Value::named("xrange")
  |
    node = rangeFunc.getACall()
  )
  or
  /* 处理 'from six.moves import range' 等特殊情况 */
  exists(string rangeName | 
    node.getNode().(Call).getFunc().(Name).getId() = rangeName |
    rangeName = "range" or rangeName = "xrange"
  )
  or
  /* 处理嵌套调用如 list(range(...)) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * 判断名称节点是否使用了非常量变量
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
    /* 变量被多次定义（动态变量） */
    strictcount(Name def | def.defines(var)) > 1
    or
    /* 变量在 for 循环中定义 */
    exists(For loop, Name def | loop.contains(def) and def.defines(var))
    or
    /* 变量在 while 循环中定义 */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * 判断循环体是否隐式重复操作 N 次（如 queue.add(None)）
 * @param loop 待检查的 for 循环
 */
predicate is_implicit_repetition(For loop) {
  /* 循环体仅包含一条语句 */
  not exists(loop.getStmt(1)) and
  /* 该语句包含不可变字面量 */
  exists(ImmutableLiteral immutableLiteral | 
    loop.getStmt(0).contains(immutableLiteral)) and
  /* 不包含使用非常量变量的名称节点 */
  not exists(Name nameNode | 
    loop.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * 获取推导式中 for 语句关联的可迭代对象的控制流节点
 * 例如：从 `{ y for y in x }` 获取 `x`
 * @param compFor 推导式中的 for 语句
 * @return 可迭代对象的控制流节点
 */
ControlFlowNode get_comprehension_iterable(For compFor) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = compFor | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * 判断变量名是否可接受为未使用变量（以下划线开头）
 * @param var 待检查的变量
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string name | name = var.getId() and name.matches("_%"))
}

/**
 * 检查 for 循环是否有未使用的迭代变量
 * @param loop 待检查的 for 循环
 * @param iterVar 未使用的迭代变量
 * @param message 警告消息
 */
predicate has_unused_iteration_variable(For loop, Variable iterVar, string message) {
  /* 循环目标变量是 iterVar */
  loop.getTarget() = iterVar.getAnAccess() and
  /* 循环体中未使用 iterVar */
  not loop.getAStmt().contains(iterVar.getAnAccess()) and
  /* 迭代器不是 range/xrange 调用 */
  not is_range_function_call(loop.getIter().getAFlowNode()) and
  /* 推导式中的迭代器也不是 range/xrange 调用 */
  not is_range_function_call(get_comprehension_iterable(loop)) and
  /* 变量名不符合未使用变量命名规范 */
  not name_acceptable_for_unused_variable(iterVar) and
  /* 不在生成器表达式中 */
  not loop.getScope().getName() = "genexpr" and
  /* 不是空循环 */
  not is_empty_loop(loop) and
  /* 不只包含单个退出语句 */
  not has_single_exit_statement(loop) and
  /* 不是计数循环 */
  not is_counting_loop(loop) and
  /* 不是隐式重复操作 */
  not is_implicit_repetition(loop) and
  /* 根据变量是否被删除设置不同消息 */
  if exists(Name delNode | delNode.deletes(iterVar) and loop.getAStmt().contains(delNode))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
}

/**
 * 识别未使用的循环迭代变量并生成警告
 */
from For loop, Variable iterVar, string message
where has_unused_iteration_variable(loop, iterVar, message)
select loop, "For loop variable '" + iterVar.getId() + message