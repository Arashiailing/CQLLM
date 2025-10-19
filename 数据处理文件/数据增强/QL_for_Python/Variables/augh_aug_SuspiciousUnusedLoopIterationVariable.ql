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
 * Determines whether a statement represents a variable increment operation.
 * Examples include x += n or x = x + n.
 * @param stmt The statement to be checked
 */
predicate is_increment_operation(Stmt stmt) {
  /* Case 1: Increment in form of x += n */
  stmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Increment in form of x = x + n */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = stmt.(AssignStmt).getTarget(0) and
    addExpr = stmt.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Determines whether a for loop is a counting loop, where the iteration variable
 * is incremented in each iteration.
 * @param forLoop The for loop to be checked
 */
predicate is_counting_loop(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * Determines whether a for loop is empty, containing only a Pass statement.
 * @param forLoop The for loop to be checked
 */
predicate is_empty_loop(For forLoop) { 
  not exists(forLoop.getStmt(1)) and 
  forLoop.getStmt(0) instanceof Pass 
}

/**
 * Determines whether a for loop contains only a single exit statement (return or break).
 * @param forLoop The for loop to be checked
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
 * Determines whether a control flow node refers to a call to range or xrange.
 * @param flowNode The control flow node to be checked
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* In Python 2, range/xrange are functions; in Python 3, they are classes */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or
    rangeFunc = Value::named("xrange")
  |
    flowNode = rangeFunc.getACall()
  )
  or
  /* Handle cases like 'from six.moves import range' where pointer analysis may fail */
  exists(string rangeName | flowNode.getNode().(Call).getFunc().(Name).getId() = rangeName |
    rangeName = "range" or rangeName = "xrange"
  )
  or
  /* Handle nested calls like list(range(...)) and list(list(range(...))) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * Determines whether a name node uses a non-constant variable.
 * @param nameNode The name node to be checked
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
 * Determines whether a loop body implicitly repeats some operation N times.
 * Example: queue.add(None)
 * @param forLoop The for loop to be checked
 */
predicate is_implicit_repetition(For forLoop) {
  /* The loop body contains only one statement */
  not exists(forLoop.getStmt(1)) and
  /* That statement contains an immutable literal */
  exists(ImmutableLiteral immLiteral | forLoop.getStmt(0).contains(immLiteral)) and
  /* No names using non-constant variables */
  not exists(Name nameNode | forLoop.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * Gets the control flow node for the iterable in a comprehension's for statement.
 * The for statement `forStmt` is an artificial for statement in a comprehension.
 * The result is the iterable in that comprehension.
 * Example: Get `x` from `{ y for y in x }`
 * @param forStmt The for statement in a comprehension
 * @return The control flow node of the iterable
 */
ControlFlowNode get_comprehension_iterable(For forStmt) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = forStmt | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines whether a variable name is acceptable for an unused variable
 * (starts with an underscore).
 * @param var The variable to be checked
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string name | name = var.getId() and name.matches("_%"))
}

/**
 * Finds unused loop iteration variables and generates appropriate warning messages.
 */
from For forLoop, Variable iterationVar, string warningMessage
where
  /* The loop target variable is iterationVar */
  forLoop.getTarget() = iterationVar.getAnAccess() and
  /* The loop increment statement does not contain iterationVar */
  not forLoop.getAStmt().contains(iterationVar.getAnAccess()) and
  /* The loop iterator is not a call to range or xrange */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* The iterator in comprehensions is also not a call to range or xrange */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* The name of iterationVar is not acceptable for an unused variable */
  not name_acceptable_for_unused_variable(iterationVar) and
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
  if exists(Name delNode | delNode.deletes(iterationVar) and forLoop.getAStmt().contains(delNode))
  then warningMessage = "' is deleted, but not used, in the loop body."
  else warningMessage = "' is not used in the loop body."
select forLoop, "For loop variable '" + iterationVar.getId() + warningMessage