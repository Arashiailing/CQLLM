/**
 * @name Suspicious unused loop iteration variable
 * @description Detects loop iteration variables that are never used, indicating a potential programming error.
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
 * Determines if a statement performs a variable increment operation (e.g., x += n or x = x + n)
 * @param statement The statement to be checked
 */
predicate is_increment_operation(Stmt statement) {
  /* Check for x += n style increment operations */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Check for x = x + n style increment operations */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = statement.(AssignStmt).getTarget(0) and
    addExpr = statement.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Determines if a for loop is a counting loop where the iteration variable is incremented each time
 * @param loop The for loop to be checked
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * Determines if a for loop is empty (contains only a Pass statement)
 * @param loop The for loop to be checked
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * Determines if a for loop contains only a single exit statement (return or break)
 * @param loop The for loop to be checked
 */
predicate has_single_exit_statement(For loop) {
  not exists(Continue c | loop.contains(c)) and
  exists(Stmt exitStatement | exitStatement = loop.getBody().getLastItem() |
    exitStatement instanceof Return
    or
    exitStatement instanceof Break
  )
}

/**
 * Determines if a control flow node points to a call to range or xrange function
 * @param node The control flow node to be checked
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* Handle range/xrange function calls in Python 2/3 */
  exists(Value rangeFunction |
    rangeFunction = Value::named("range") or
    rangeFunction = Value::named("xrange")
  |
    node = rangeFunction.getACall()
  )
  or
  /* Handle direct calls using range/xrange names */
  exists(string funcName | node.getNode().(Call).getFunc().(Name).getId() = funcName |
    funcName = "range" or funcName = "xrange"
  )
  or
  /* Handle nested calls like list(range(...)) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * Determines if a name node uses a non-constant variable
 * @param nameNode The name node to be checked
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable variableRef |
    nameNode.uses(variableRef) and
    /* Ensure the usage is local */
    not nameNode.getScope() instanceof Module and
    /* Ensure the variable is not global */
    not variableRef.getScope() instanceof Module
  |
    /* Variable is defined multiple times (dynamic) */
    strictcount(Name definition | definition.defines(variableRef)) > 1
    or
    /* Variable is defined within a for loop */
    exists(For loop, Name definition | loop.contains(definition) and definition.defines(variableRef))
    or
    /* Variable is defined within a while loop */
    exists(While whileLoop, Name definition | whileLoop.contains(definition) and definition.defines(variableRef))
  )
}

/**
 * Determines if a loop body implicitly repeats some operation N times
 * Example: queue.add(None)
 * @param loop The for loop to be checked
 */
predicate is_implicit_repetition(For loop) {
  /* Loop body contains only one statement */
  not exists(loop.getStmt(1)) and
  /* The statement contains an immutable literal */
  exists(ImmutableLiteral literal | loop.getStmt(0).contains(literal)) and
  /* Does not contain names using non-constant variables */
  not exists(Name nameNode | loop.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * Retrieves the control flow graph node for the iterable in a comprehension's for statement
 * The for statement `compFor` is an artificial for statement within a comprehension
 * The result is the iterable in that comprehension
 * Example: from `{ y for y in x }` retrieve `x`
 * @param compFor The for statement in a comprehension
 * @return The control flow node of the iterable
 */
ControlFlowNode get_comprehension_iterable(For compFor) {
  exists(Comp compExpr | 
    compExpr.getFunction().getStmt(0) = compFor | 
    compExpr.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines if a variable name is appropriate for an unused variable (starts with underscore)
 * @param var The variable to be checked
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string name | name = var.getId() and name.matches("_%"))
}

/**
 * Identifies unused loop iteration variables and generates corresponding warning messages
 */
from For loop, Variable iterVar, string warningMsg
where
  /* The loop target variable is iterVar */
  loop.getTarget() = iterVar.getAnAccess() and
  /* The loop increment statement doesn't contain iterVar */
  not loop.getAStmt().contains(iterVar.getAnAccess()) and
  /* The loop iterator is not a call to range or xrange */
  not is_range_function_call(loop.getIter().getAFlowNode()) and
  /* The iterator in comprehensions is also not a call to range or xrange */
  not is_range_function_call(get_comprehension_iterable(loop)) and
  /* The iterVar name is not appropriate for an unused variable */
  not name_acceptable_for_unused_variable(iterVar) and
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
  if exists(Name deleteNode | deleteNode.deletes(iterVar) and loop.getAStmt().contains(deleteNode))
  then warningMsg = "' is deleted, but not used, in the loop body."
  else warningMsg = "' is not used in the loop body."
select loop, "For loop variable '" + iterVar.getId() + warningMsg