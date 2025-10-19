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
 * Determines if a statement represents a variable increment operation,
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
 * Determines if a for loop is a counting loop,
 * where the iteration variable is incremented in each iteration.
 * @param loop The for loop to be checked.
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * Determines if a for loop is an empty loop,
 * containing only a Pass statement.
 * @param loop The for loop to be checked.
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * Determines if a for loop contains only a single exit statement
 * (return or break) without any continue statements.
 * @param loop The for loop to be checked.
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
 * Determines if a control flow node points to a call to range or xrange.
 * @param node The control flow node to be checked.
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* In Python 2, range/xrange are functions, in Python 3 they are classes,
     so they need to be handled as regular objects */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or
    rangeFunc = Value::named("xrange")
  |
    node = rangeFunc.getACall()
  )
  or
  /* Handle cases like 'from six.moves import range' that may cause
     pointer analysis failures */
  exists(string rangeName | 
    node.getNode().(Call).getFunc().(Name).getId() = rangeName |
    rangeName = "range" or rangeName = "xrange"
  )
  or
  /* Handle nested calls like list(range(...)) and list(list(range(...))) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * Determines if a name node uses a non-constant variable.
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
    exists(For loop, Name def | loop.contains(def) and def.defines(var))
    or
    /* The variable is defined in a while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * Determines if the loop body implicitly repeats some operation N times.
 * For example: queue.add(None)
 * @param loop The for loop to be checked.
 */
predicate is_implicit_repetition(For loop) {
  /* The loop body contains only one statement */
  not exists(loop.getStmt(1)) and
  /* That statement contains an immutable literal */
  exists(ImmutableLiteral immutableLiteral | 
    loop.getStmt(0).contains(immutableLiteral)) and
  /* Does not contain names that use non-constant variables */
  not exists(Name nameNode | 
    loop.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * Gets the control flow graph node for the iterable object associated with
 * a for statement in a comprehension. The for statement `compFor`
 * is an artificial for statement in the comprehension. The result is the
 * iterable in that comprehension.
 * For example: from `{ y for y in x }` get `x`
 * @param compFor The for statement in the comprehension.
 * @return The control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For compFor) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = compFor | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines if the variable name is acceptable for an unused variable
 * (starts with an underscore).
 * @param var The variable to be checked.
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string name | name = var.getId() and name.matches("_%"))
}

/**
 * Checks if a for loop has an unused iteration variable.
 * @param loop The for loop to be checked.
 * @param iterVar The iteration variable that is unused.
 * @param message The warning message to be displayed.
 */
predicate has_unused_iteration_variable(For loop, Variable iterVar, string message) {
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
  if exists(Name delNode | delNode.deletes(iterVar) and loop.getAStmt().contains(delNode))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
}

/**
 * Identifies unused loop iteration variables and generates appropriate warning messages.
 */
from For loop, Variable iterVar, string message
where has_unused_iteration_variable(loop, iterVar, message)
select loop, "For loop variable '" + iterVar.getId() + message