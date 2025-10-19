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
 * 检测一个语句是否执行了变量的递增操作（例如 x += n 或 x = x + n）
 * @param statement 待检查的语句
 */
predicate is_increment_operation(Stmt statement) {
  /* 情况1：x += n 形式的自增 */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* 情况2：x = x + n 形式的自增 */
  exists(Name targetVariable, BinaryExpr additionExpression |
    targetVariable = statement.(AssignStmt).getTarget(0) and
    additionExpression = statement.(AssignStmt).getValue() and
    additionExpression.getLeft().(Name).getVariable() = targetVariable.getVariable() and
    additionExpression.getRight() instanceof IntegerLiteral
  )
}

/**
 * 判断 for 循环是否为计数循环（每次迭代中迭代变量都会自增）
 * @param forLoop 待检查的 for 循环
 */
predicate is_counting_loop(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * 判断 for 循环是否为空循环（仅包含 Pass 语句）
 * @param forLoop 待检查的 for 循环
 */
predicate is_empty_loop(For forLoop) { 
  not exists(forLoop.getStmt(1)) and 
  forLoop.getStmt(0) instanceof Pass 
}

/**
 * 判断 for 循环是否仅包含单个退出语句（return 或 break）且无 continue
 * @param forLoop 待检查的 for 循环
 */
predicate has_single_exit_statement(For forLoop) {
  not exists(Continue continueStmt | forLoop.contains(continueStmt)) and
  exists(Stmt finalStatement | finalStatement = forLoop.getBody().getLastItem() |
    finalStatement instanceof Return
    or
    finalStatement instanceof Break
  )
}

/**
 * 判断控制流节点是否指向 range 或 xrange 函数调用
 * @param flowNode 待检查的控制流节点
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* Python 2/3 兼容性处理：range/xrange 作为常规对象 */
  exists(Value rangeFunction |
    rangeFunction = Value::named("range") or
    rangeFunction = Value::named("xrange")
  |
    flowNode = rangeFunction.getACall()
  )
  or
  /* 处理 'from six.moves import range' 等特殊情况 */
  exists(string rangeIdentifier | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = rangeIdentifier |
    rangeIdentifier = "range" or rangeIdentifier = "xrange"
  )
  or
  /* 处理嵌套调用如 list(range(...)) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * 判断名称节点是否使用了非常量变量
 * @param nameExpression 待检查的名称节点
 */
predicate uses_non_constant_variable(Name nameExpression) {
  exists(Variable variable |
    nameExpression.uses(variable) and
    /* 使用是局部的 */
    not nameExpression.getScope() instanceof Module and
    /* 变量不是全局的 */
    not variable.getScope() instanceof Module
  |
    /* 变量被多次定义（动态变量） */
    strictcount(Name definition | definition.defines(variable)) > 1
    or
    /* 变量在 for 循环中定义 */
    exists(For forLoop, Name definition | forLoop.contains(definition) and definition.defines(variable))
    or
    /* 变量在 while 循环中定义 */
    exists(While whileStatement, Name definition | whileStatement.contains(definition) and definition.defines(variable))
  )
}

/**
 * 判断循环体是否隐式重复操作 N 次（如 queue.add(None)）
 * @param forLoop 待检查的 for 循环
 */
predicate is_implicit_repetition(For forLoop) {
  /* 循环体仅包含一条语句 */
  not exists(forLoop.getStmt(1)) and
  /* 该语句包含不可变字面量 */
  exists(ImmutableLiteral constantLiteral | 
    forLoop.getStmt(0).contains(constantLiteral)) and
  /* 不包含使用非常量变量的名称节点 */
  not exists(Name nameExpression | 
    forLoop.getBody().contains(nameExpression) and uses_non_constant_variable(nameExpression))
}

/**
 * 获取推导式中 for 语句关联的可迭代对象的控制流节点
 * 例如：从 `{ y for y in x }` 获取 `x`
 * @param comprehensionFor 推导式中的 for 语句
 * @return 可迭代对象的控制流节点
 */
ControlFlowNode get_comprehension_iterable(For comprehensionFor) {
  exists(Comp comprehensionExpr | 
    comprehensionExpr.getFunction().getStmt(0) = comprehensionFor | 
    comprehensionExpr.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * 判断变量名是否可接受为未使用变量（以下划线开头）
 * @param variable 待检查的变量
 */
predicate name_acceptable_for_unused_variable(Variable variable) {
  exists(string name | name = variable.getId() and name.matches("_%"))
}

/**
 * 检查 for 循环是否有未使用的迭代变量
 * @param forLoop 待检查的 for 循环
 * @param iterVar 未使用的迭代变量
 * @param message 警告消息
 */
predicate has_unused_iteration_variable(For forLoop, Variable iterVar, string message) {
  /* 循环目标变量是 iterVar */
  forLoop.getTarget() = iterVar.getAnAccess() and
  /* 循环体中未使用 iterVar */
  not forLoop.getAStmt().contains(iterVar.getAnAccess()) and
  /* 迭代器不是 range/xrange 调用 */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* 推导式中的迭代器也不是 range/xrange 调用 */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* 变量名不符合未使用变量命名规范 */
  not name_acceptable_for_unused_variable(iterVar) and
  /* 不在生成器表达式中 */
  not forLoop.getScope().getName() = "genexpr" and
  /* 不是空循环 */
  not is_empty_loop(forLoop) and
  /* 不只包含单个退出语句 */
  not has_single_exit_statement(forLoop) and
  /* 不是计数循环 */
  not is_counting_loop(forLoop) and
  /* 不是隐式重复操作 */
  not is_implicit_repetition(forLoop) and
  /* 根据变量是否被删除设置不同消息 */
  if exists(Name deletionNode | deletionNode.deletes(iterVar) and forLoop.getAStmt().contains(deletionNode))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
}

/**
 * 识别未使用的循环迭代变量并生成警告
 */
from For forLoop, Variable iterVar, string message
where has_unused_iteration_variable(forLoop, iterVar, message)
select forLoop, "For loop variable '" + iterVar.getId() + message