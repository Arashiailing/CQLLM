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
import Definition

// 判断语句是否为递增操作，例如 x += n 或 x = x + n
predicate is_increment(Stmt s) {
  /* x += n */
  s.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* x = x + n */
  exists(Name t, BinaryExpr add |
    t = s.(AssignStmt).getTarget(0) and
    add = s.(AssignStmt).getValue() and
    add.getLeft().(Name).getVariable() = t.getVariable() and
    add.getRight() instanceof IntegerLiteral
  )
}

// 判断 for 循环是否为计数循环，即每次迭代变量递增
predicate counting_loop(For f) { is_increment(f.getAStmt()) }

// 判断 for 循环是否为空循环，即循环体只有一个 Pass 语句
predicate empty_loop(For f) { not exists(f.getStmt(1)) and f.getStmt(0) instanceof Pass }

// 判断 for 循环是否只包含一个返回或中断语句
predicate one_item_only(For f) {
  not exists(Continue c | f.contains(c)) and
  exists(Stmt s | s = f.getBody().getLastItem() |
    s instanceof Return
    or
    s instanceof Break
  )
}

// 判断控制流节点是否指向对 range 或 xrange 的调用
predicate points_to_call_to_range(ControlFlowNode f) {
  /* (x)range is a function in Py2 and a class in Py3, so we must treat it as a plain object */
  exists(Value range |
    range = Value::named("range") or
    range = Value::named("xrange")
  |
    f = range.getACall()
  )
  or
  /* In case points-to fails due to 'from six.moves import range' or similar. */
  exists(string range | f.getNode().(Call).getFunc().(Name).getId() = range |
    range = "range" or range = "xrange"
  )
  or
  /* Handle list(range(...)) and list(list(range(...))) */
  f.(CallNode).pointsTo().getClass() = ClassValue::list() and
  points_to_call_to_range(f.(CallNode).getArg(0))
}

/** Whether n is a use of a variable that is a not effectively a constant. */
// 判断名称 n 是否使用了非常量的变量
predicate use_of_non_constant(Name n) {
  exists(Variable var |
    n.uses(var) and
    /* use is local */
    not n.getScope() instanceof Module and
    /* variable is not global */
    not var.getScope() instanceof Module
  |
    /* Defined more than once (dynamically) */
    strictcount(Name def | def.defines(var)) > 1
    or
    exists(For f, Name def | f.contains(def) and def.defines(var))
    or
    exists(While w, Name def | w.contains(def) and def.defines(var))
  )
}

/**
 * Whether loop body is implicitly repeating something N times.
 * E.g. queue.add(None)
 */
// 判断循环体是否隐式地重复了某些操作，例如 queue.add(None)
predicate implicit_repeat(For f) {
  not exists(f.getStmt(1)) and
  exists(ImmutableLiteral imm | f.getStmt(0).contains(imm)) and
  not exists(Name n | f.getBody().contains(n) and use_of_non_constant(n))
}

/**
 * Get the CFG node for the iterable relating to the for-statement `f` in a comprehension.
 * The for-statement `f` is the artificial for-statement in a comprehension
 * and the result is the iterable in that comprehension.
 * E.g. gets `x` from `{ y for y in x }`.
 */
// 获取与理解中的 for 语句相关的可迭代对象的控制流图节点
ControlFlowNode get_comp_iterable(For f) {
  exists(Comp c | c.getFunction().getStmt(0) = f | c.getAFlowNode().getAPredecessor() = result)
}

// 查询未使用的循环迭代变量，并生成相应的警告信息
from For f, Variable v, string msg
where
  f.getTarget() = v.getAnAccess() and // 循环目标变量是 v
  not f.getAStmt().contains(v.getAnAccess()) and // 循环增量语句中不包含 v
  not points_to_call_to_range(f.getIter().getAFlowNode()) and // 循环迭代器不是对 range 或 xrange 的调用
  not points_to_call_to_range(get_comp_iterable(f)) and // 理解中的迭代器也不是对 range 或 xrange 的调用
  not name_acceptable_for_unused_variable(v) and // v 的名称不适合作为未使用变量
  not f.getScope().getName() = "genexpr" and // 不在生成器表达式中
  not empty_loop(f) and // 不是空循环
  not one_item_only(f) and // 不只包含一个返回或中断语句
  not counting_loop(f) and // 不是计数循环
  not implicit_repeat(f) and // 不是隐式重复操作
  if exists(Name del | del.deletes(v) and f.getAStmt().contains(del)) // 如果 v 在循环体内被删除
  then msg = "' is deleted, but not used, in the loop body." // 设置消息为“在循环体内被删除但未使用”
  else msg = "' is not used in the loop body." // 否则设置消息为“在循环体内未使用”
select f, "For loop variable '" + v.getId() + msg // 选择循环和相应的警告信息
