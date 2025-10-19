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
 * Check if the statement is an increment operation (e.g., x += n or x = x + n).
 * @param incrementStmt The statement to be checked.
 */
predicate is_increment_operation(Stmt incrementStmt) {
  /* Case 1: Increment in the form x += n */
  incrementStmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Increment in the form x = x + n */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = incrementStmt.(AssignStmt).getTarget(0) and
    addExpr = incrementStmt.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Check if the for loop is a counting loop (i.e., the iteration variable is incremented in each iteration).
 * @param countingLoop The for loop to be checked.
 */
predicate is_counting_loop(For countingLoop) { 
  is_increment_operation(countingLoop.getAStmt()) 
}

/**
 * Check if the for loop is empty (i.e., contains only a Pass statement).
 * @param emptyLoop The for loop to be checked.
 */
predicate is_empty_loop(For emptyLoop) { 
  not exists(emptyLoop.getStmt(1)) and 
  emptyLoop.getStmt(0) instanceof Pass 
}

/**
 * Check if the for loop has only one exit statement (return or break) and no continue statements.
 * @param loopWithExit The for loop to be checked.
 */
predicate has_single_exit_statement(For loopWithExit) {
  not exists(Continue c | loopWithExit.contains(c)) and
  exists(Stmt lastStmt | lastStmt = loopWithExit.getBody().getLastItem() |
    lastStmt instanceof Return
    or
    lastStmt instanceof Break
  )
}

/**
 * Check if the control flow node is a call to range or xrange.
 * @param node The control flow node to be checked.
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* In Python 2, range/xrange are functions, in Python 3 they are classes,
     so they need to be handled as regular objects */
  exists(Value rangeOrXrange |
    rangeOrXrange = Value::named("range") or
    rangeOrXrange = Value::named("xrange")
  |
    node = rangeOrXrange.getACall()
  )
  or
  /* Handle cases like 'from six.moves import range' that may cause
     pointer analysis failures */
  exists(string funcName | 
    node.getNode().(Call).getFunc().(Name).getId() = funcName |
    funcName = "range" or funcName = "xrange"
  )
  or
  /* Handle nested calls like list(range(...)) and list(list(range(...))) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * Check if the name node uses a non-constant variable.
 * @param nameNode The name node to be checked.
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable var |
    nameNode.uses(var) and
    /* The usage is local */
    not nameNode.getScope() instanceof Module and
    /* The variable is not global */
    not var.getScope() instanceof Module
  |
    /* The variable is defined multiple times (dynamic) */
    strictcount(Name def | def.defines(var)) > 1
    or
    /* The variable is defined in a for loop */
    exists(For forLoop, Name def | forLoop.contains(def) and def.defines(var))
    or
    /* The variable is defined in a while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * Check if the loop body implicitly repeats an operation N times (e.g., queue.add(None)).
 * @param loop The for loop to be checked.
 */
predicate is_implicit_repetition(For loop) {
  /* The loop body contains only one statement */
  not exists(loop.getStmt(1)) and
  /* That statement contains an immutable literal */
  exists(ImmutableLiteral literal | 
    loop.getStmt(0).contains(literal)) and
  /* Does not contain names that use non-constant variables */
  not exists(Name nameNode | 
    loop.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * Get the control flow node of the iterable in a comprehension's for statement.
 * For example, in `{ y for y in x }`, return the node for `x`.
 * @param compFor The for statement in the comprehension.
 * @return The control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For compFor) {
  exists(Comp comp | 
    comp.getFunction().getStmt(0) = compFor | 
    comp.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Check if the variable name is acceptable for an unused variable (i.e., starts with an underscore).
 * @param var The variable to be checked.
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string name | name = var.getId() and name.matches("_%"))
}

/**
 * Find unused loop iteration variables and generate appropriate warning messages.
 */
from For loop, Variable iterVar, string msg
where
  /* The loop target variable is iterVar */
  loop.getTarget() = iterVar.getAnAccess() and
  /* The loop increment statement does not contain iterVar */
  not loop.getAStmt().contains(iterVar.getAnAccess()) and
  /* The loop iterator is not a call to range or xrange */
  not is_range_function_call(loop.getIter().getAFlowNode()) and
  /* The iterator in comprehensions is also not a call to range or xrange */
  not is_range_function_call(get_comprehension_iterable(loop)) and
  /* The name of iterVar is not acceptable for an unused variable */
  not name_acceptable_for_unused_variable(iterVar) and
  /* Not in a generator expression */
  not loop.getScope().getName() = "genexpr" and
  /* Not an empty loop */
  not is_empty_loop(loop) and
  /* Does not contain only a single exit statement */
  not has_single_exit_statement(loop) and
  /* Not a counting loop */
  not is_counting_loop(loop) and
  /* Not an implicit repetition operation */
  not is_implicit_repetition(loop) and
  /* Set different warning messages based on whether the variable is deleted in the loop body */
  if exists(Name delStmt | delStmt.deletes(iterVar) and loop.getAStmt().contains(delStmt))
  then msg = "' is deleted, but not used, in the loop body."
  else msg = "' is not used in the loop body."
select loop, "For loop variable '" + iterVar.getId() + msg