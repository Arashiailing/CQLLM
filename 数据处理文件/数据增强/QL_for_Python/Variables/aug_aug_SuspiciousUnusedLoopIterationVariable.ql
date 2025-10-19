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
 * Determines if the given statement represents a variable increment operation,
 * such as x += n or x = x + n.
 * @param stmt The statement to be checked.
 */
predicate is_increment_operation(Stmt stmt) {
  /* Case 1: Increment in the form x += n */
  stmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Increment in the form x = x + n */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = stmt.(AssignStmt).getTarget(0) and
    addExpr = stmt.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Determines if the given for loop is a counting loop,
 * where the iteration variable is incremented in each iteration.
 * @param forLoop The for loop to be checked.
 */
predicate is_counting_loop(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * Determines if the given for loop is an empty loop,
 * containing only a Pass statement.
 * @param forLoop The for loop to be checked.
 */
predicate is_empty_loop(For forLoop) { 
  not exists(forLoop.getStmt(1)) and 
  forLoop.getStmt(0) instanceof Pass 
}

/**
 * Determines if the given for loop contains only a single exit statement
 * (return or break) without any continue statements.
 * @param forLoop The for loop to be checked.
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
 * Determines if the control flow node points to a call to range or xrange.
 * @param controlFlowNode The control flow node to be checked.
 */
predicate is_range_function_call(ControlFlowNode controlFlowNode) {
  /* In Python 2, range/xrange are functions, in Python 3 they are classes,
     so they need to be handled as regular objects */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or
    rangeFunc = Value::named("xrange")
  |
    controlFlowNode = rangeFunc.getACall()
  )
  or
  /* Handle cases like 'from six.moves import range' that may cause
     pointer analysis failures */
  exists(string rangeName | 
    controlFlowNode.getNode().(Call).getFunc().(Name).getId() = rangeName |
    rangeName = "range" or rangeName = "xrange"
  )
  or
  /* Handle nested calls like list(range(...)) and list(list(range(...))) */
  controlFlowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(controlFlowNode.(CallNode).getArg(0))
}

/**
 * Determines if the given name node uses a non-constant variable.
 * @param nameExpr The name node to be checked.
 */
predicate uses_non_constant_variable(Name nameExpr) {
  exists(Variable variable |
    nameExpr.uses(variable) and
    /* The usage is local */
    not nameExpr.getScope() instanceof Module and
    /* The variable is not global */
    not variable.getScope() instanceof Module
  |
    /* The variable is defined multiple times (dynamic) */
    strictcount(Name def | def.defines(variable)) > 1
    or
    /* The variable is defined in a for loop */
    exists(For forLoop, Name def | forLoop.contains(def) and def.defines(variable))
    or
    /* The variable is defined in a while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(variable))
  )
}

/**
 * Determines if the loop body implicitly repeats some operation N times.
 * For example: queue.add(None)
 * @param forLoop The for loop to be checked.
 */
predicate is_implicit_repetition(For forLoop) {
  /* The loop body contains only one statement */
  not exists(forLoop.getStmt(1)) and
  /* That statement contains an immutable literal */
  exists(ImmutableLiteral immutableLiteral | 
    forLoop.getStmt(0).contains(immutableLiteral)) and
  /* Does not contain names that use non-constant variables */
  not exists(Name nameExpr | 
    forLoop.getBody().contains(nameExpr) and uses_non_constant_variable(nameExpr))
}

/**
 * Gets the control flow graph node for the iterable object associated with
 * a for statement in a comprehension. The for statement `comprehensionFor`
 * is an artificial for statement in the comprehension. The result is the
 * iterable in that comprehension.
 * For example: from `{ y for y in x }` get `x`
 * @param comprehensionFor The for statement in the comprehension.
 * @return The control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For comprehensionFor) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = comprehensionFor | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines if the variable name is acceptable for an unused variable
 * (starts with an underscore).
 * @param variable The variable to be checked.
 */
predicate name_acceptable_for_unused_variable(Variable variable) {
  exists(string name | name = variable.getId() and name.matches("_%"))
}

/**
 * Finds unused loop iteration variables and generates appropriate warning messages.
 */
from For forLoop, Variable iterationVariable, string message
where
  /* The loop target variable is iterationVariable */
  forLoop.getTarget() = iterationVariable.getAnAccess() and
  /* The loop increment statement does not contain iterationVariable */
  not forLoop.getAStmt().contains(iterationVariable.getAnAccess()) and
  /* The loop iterator is not a call to range or xrange */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* The iterator in comprehensions is also not a call to range or xrange */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* The name of iterationVariable is not acceptable for an unused variable */
  not name_acceptable_for_unused_variable(iterationVariable) and
  /* Not in a generator expression */
  not forLoop.getScope().getName() = "genexpr" and
  /* Not an empty loop */
  not is_empty_loop(forLoop) and
  /* Does not contain only a single exit statement */
  not has_single_exit_statement(forLoop) and
  /* Not a counting loop */
  not is_counting_loop(forLoop) and
  /* Not an implicit repetition operation */
  not is_implicit_repetition(forLoop) and
  /* Set different warning messages based on whether the variable is deleted in the loop body */
  if exists(Name delNode | delNode.deletes(iterationVariable) and forLoop.getAStmt().contains(delNode))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
select forLoop, "For loop variable '" + iterationVariable.getId() + message