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
 * Determines if the given statement is a variable increment operation, such as x += n or x = x + n
 * @param statement The statement to be checked
 */
predicate is_increment_operation(Stmt statement) {
  /* Check for increment operations in the form x += n */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Check for increment operations in the form x = x + n */
  exists(Name targetVariable, BinaryExpr additionExpr |
    targetVariable = statement.(AssignStmt).getTarget(0) and
    additionExpr = statement.(AssignStmt).getValue() and
    additionExpr.getLeft().(Name).getVariable() = targetVariable.getVariable() and
    additionExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Determines if the given for loop is a counting loop, where the iteration variable increments each time
 * @param loop The for loop to be checked
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * Determines if the given for loop is an empty loop, i.e., the loop body only contains a Pass statement
 * @param loop The for loop to be checked
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * Determines if the given for loop only contains a return or break statement
 * @param loop The for loop to be checked
 */
predicate has_single_exit_statement(For loop) {
  not exists(Continue continueStmt | loop.contains(continueStmt)) and
  exists(Stmt finalStatement | finalStatement = loop.getBody().getLastItem() |
    finalStatement instanceof Return
    or
    finalStatement instanceof Break
  )
}

/**
 * Determines if a control flow node points to a call to range or xrange
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
  exists(string functionName | node.getNode().(Call).getFunc().(Name).getId() = functionName |
    functionName = "range" or functionName = "xrange"
  )
  or
  /* Handle nested calls, such as list(range(...)) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * Determines if a name node uses a non-constant variable
 * @param nameNode The name node to be checked
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable variable |
    nameNode.uses(variable) and
    /* Ensure the usage is local */
    not nameNode.getScope() instanceof Module and
    /* Ensure the variable is not global */
    not variable.getScope() instanceof Module
  |
    /* The variable is defined multiple times (dynamic) */
    strictcount(Name definition | definition.defines(variable)) > 1
    or
    /* The variable is defined in a for loop */
    exists(For loop, Name definition | loop.contains(definition) and definition.defines(variable))
    or
    /* The variable is defined in a while loop */
    exists(While loop, Name definition | loop.contains(definition) and definition.defines(variable))
  )
}

/**
 * Determines if a loop body implicitly repeats some operation N times
 * For example: queue.add(None)
 * @param loop The for loop to be checked
 */
predicate is_implicit_repetition(For loop) {
  /* The loop body has only one statement */
  not exists(loop.getStmt(1)) and
  /* That statement contains an immutable literal */
  exists(ImmutableLiteral literal | loop.getStmt(0).contains(literal)) and
  /* Does not contain names that use non-constant variables */
  not exists(Name varName | loop.getBody().contains(varName) and uses_non_constant_variable(varName))
}

/**
 * Gets the control flow graph node related to the iterable in a comprehension
 * The for statement `comprehensionFor` is an artificial for statement in a comprehension
 * The result is the iterable in that comprehension
 * For example: from `{ y for y in x }` get `x`
 * @param comprehensionFor The for statement in the comprehension
 * @return The control flow node of the iterable
 */
ControlFlowNode get_comprehension_iterable(For comprehensionFor) {
  exists(Comp comprehensionExpr | 
    comprehensionExpr.getFunction().getStmt(0) = comprehensionFor | 
    comprehensionExpr.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines if a variable name is suitable for an unused variable (starts with an underscore)
 * @param variable The variable to be checked
 */
predicate name_acceptable_for_unused_variable(Variable variable) {
  exists(string varName | varName = variable.getId() and varName.matches("_%"))
}

/**
 * Finds unused loop iteration variables and generates corresponding warning messages
 */
from For loop, Variable iterationVariable, string warningMessage
where
  /* The loop target variable is iterationVariable */
  loop.getTarget() = iterationVariable.getAnAccess() and
  /* The loop increment statement does not contain iterationVariable */
  not loop.getAStmt().contains(iterationVariable.getAnAccess()) and
  /* The loop iterator is not a call to range or xrange */
  not is_range_function_call(loop.getIter().getAFlowNode()) and
  /* The iterator in comprehensions is also not a call to range or xrange */
  not is_range_function_call(get_comprehension_iterable(loop)) and
  /* The name of iterationVariable is not suitable for an unused variable */
  not name_acceptable_for_unused_variable(iterationVariable) and
  /* Not in a generator expression */
  not loop.getScope().getName() = "genexpr" and
  /* Not an empty loop */
  not is_empty_loop(loop) and
  /* Does not only contain a return or break statement */
  not has_single_exit_statement(loop) and
  /* Not a counting loop */
  not is_counting_loop(loop) and
  /* Not an implicit repetition operation */
  not is_implicit_repetition(loop) and
  /* Set different warning messages based on whether the variable is deleted in the loop body */
  if exists(Name deletionNode | deletionNode.deletes(iterationVariable) and loop.getAStmt().contains(deletionNode))
  then warningMessage = "' is deleted, but not used, in the loop body."
  else warningMessage = "' is not used in the loop body."
select loop, "For loop variable '" + iterationVariable.getId() + warningMessage