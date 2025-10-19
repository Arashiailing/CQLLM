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
 * Determines if a statement represents a variable increment operation.
 * This includes forms like x += n or x = x + n.
 * @param statement The statement to check.
 */
predicate represents_increment_operation(Stmt statement) {
  /* Case 1: Increment in form x += n */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Increment in form x = x + n */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = statement.(AssignStmt).getTarget(0) and
    addExpr = statement.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Determines if a for loop is a counting loop where the iteration variable
 * is incremented in each iteration.
 * @param loop The for loop to check.
 */
predicate is_counting_loop(For loop) { 
  represents_increment_operation(loop.getAStmt()) 
}

/**
 * Determines if a for loop is an empty loop, containing only a Pass statement.
 * @param loop The for loop to check.
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * Determines if a for loop contains only a single exit statement (return or break)
 * and no continue statements.
 * @param loop The for loop to check.
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
 * Determines if a control flow node refers to a call to range or xrange function.
 * @param node The control flow node to check.
 */
predicate refers_to_range_function(ControlFlowNode node) {
  /* In Python 2, range/xrange are functions, in Python 3 they are classes,
     so we need to handle them as ordinary objects */
  exists(Value rangeVal |
    rangeVal = Value::named("range") or
    rangeVal = Value::named("xrange")
  |
    node = rangeVal.getACall()
  )
  or
  /* Handle cases like 'from six.moves import range' where pointer analysis might fail */
  exists(string rangeName | node.getNode().(Call).getFunc().(Name).getId() = rangeName |
    rangeName = "range" or rangeName = "xrange"
  )
  or
  /* Handle nested calls like list(range(...)) and list(list(range(...))) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  refers_to_range_function(node.(CallNode).getArg(0))
}

/**
 * Determines if a name node uses a non-constant variable.
 * @param nameRef The name node to check.
 */
predicate uses_non_constant_variable(Name nameRef) {
  exists(Variable var |
    nameRef.uses(var) and
    /* The usage is local */
    not nameRef.getScope() instanceof Module and
    /* The variable is not global */
    not var.getScope() instanceof Module
  |
    /* The variable is defined multiple times (dynamic) */
    strictcount(Name def | def.defines(var)) > 1
    or
    /* The variable is defined in a for loop */
    exists(For loop, Name def | loop.contains(def) and def.defines(var))
    or
    /* The variable is defined in a while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * Determines if a loop body implicitly repeats certain operations N times.
 * For example: queue.add(None)
 * @param loop The for loop to check.
 */
predicate is_implicit_repetition(For loop) {
  /* The loop body contains only one statement */
  not exists(loop.getStmt(1)) and
  /* That statement contains an immutable literal */
  exists(ImmutableLiteral immLiteral | loop.getStmt(0).contains(immLiteral)) and
  /* It doesn't contain names that use non-constant variables */
  not exists(Name nameRef | loop.getBody().contains(nameRef) and uses_non_constant_variable(nameRef))
}

/**
 * Gets the control flow node for the iterable in a comprehension's for statement.
 * The for statement `comprehensionLoop` is an artificial for statement in a comprehension.
 * The result is the iterable in that comprehension.
 * For example, from `{ y for y in x }` get `x`.
 * @param comprehensionLoop The for statement in a comprehension.
 * @return The control flow node for the iterable.
 */
ControlFlowNode get_comprehension_iterable(For comprehensionLoop) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = comprehensionLoop | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines if a variable name is acceptable for an unused variable
 * (starts with an underscore).
 * @param variable The variable to check.
 */
predicate is_name_acceptable_for_unused_variable(Variable variable) {
  exists(string name | name = variable.getId() and name.matches("_%"))
}

/**
 * Finds unused loop iteration variables and generates appropriate warning messages.
 */
from For loop, Variable iterVar, string msg
where
  /* The loop target variable is iterVar */
  loop.getTarget() = iterVar.getAnAccess() and
  /* The loop increment statement doesn't contain iterVar */
  not loop.getAStmt().contains(iterVar.getAnAccess()) and
  /* The loop iterator is not a call to range or xrange */
  not refers_to_range_function(loop.getIter().getAFlowNode()) and
  /* The iterator in a comprehension is also not a call to range or xrange */
  not refers_to_range_function(get_comprehension_iterable(loop)) and
  /* The name of iterVar is not acceptable for an unused variable */
  not is_name_acceptable_for_unused_variable(iterVar) and
  /* Not in a generator expression */
  not loop.getScope().getName() = "genexpr" and
  /* Not an empty loop */
  not is_empty_loop(loop) and
  /* Doesn't contain only a single exit statement */
  not has_single_exit_statement(loop) and
  /* Not a counting loop */
  not is_counting_loop(loop) and
  /* Not an implicit repetition operation */
  not is_implicit_repetition(loop) and
  /* Set different warning messages based on whether the variable is deleted in the loop body */
  if exists(Name delNode | delNode.deletes(iterVar) and loop.getAStmt().contains(delNode))
  then msg = "' is deleted, but not used, in the loop body."
  else msg = "' is not used in the loop body."
select loop, "For loop variable '" + iterVar.getId() + msg