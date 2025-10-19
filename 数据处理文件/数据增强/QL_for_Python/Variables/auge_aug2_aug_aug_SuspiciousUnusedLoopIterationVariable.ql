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
 * Checks if a statement is an augmented assignment with an integer literal.
 * @param statement The statement to check.
 */
predicate is_augmented_increment(Stmt statement) {
  statement.(AugAssign).getValue() instanceof IntegerLiteral
}

/**
 * Checks if a statement is an assignment with addition of an integer literal.
 * @param statement The statement to check.
 */
predicate is_assignment_increment(Stmt statement) {
  exists(Name targetVariable, BinaryExpr additionExpr |
    targetVariable = statement.(AssignStmt).getTarget(0) and
    additionExpr = statement.(AssignStmt).getValue() and
    additionExpr.getLeft().(Name).getVariable() = targetVariable.getVariable() and
    additionExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Determines if a statement represents a variable increment operation.
 * @param statement The statement to be checked.
 */
predicate is_increment_operation(Stmt statement) {
  is_augmented_increment(statement) or is_assignment_increment(statement)
}

/**
 * Determines if a for loop is a counting loop,
 * where the iteration variable is incremented in each iteration.
 * @param forLoop The for loop to be checked.
 */
predicate is_counting_loop(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * Determines if a for loop is an empty loop or contains only a single exit statement.
 * @param forLoop The for loop to be checked.
 */
predicate is_trivial_loop(For forLoop) {
  /* Empty loop case */
  (not exists(forLoop.getStmt(1)) and forLoop.getStmt(0) instanceof Pass)
  or
  /* Single exit statement case */
  (not exists(Continue continueStmt | forLoop.contains(continueStmt)) and
   exists(Stmt lastStatement | lastStatement = forLoop.getBody().getLastItem() |
     lastStatement instanceof Return or lastStatement instanceof Break))
}

/**
 * Determines if a control flow node points to a direct range/xrange call.
 * @param flowNode The control flow node to be checked.
 */
predicate is_direct_range_call(ControlFlowNode flowNode) {
  exists(Value rangeFunction |
    rangeFunction = Value::named("range") or rangeFunction = Value::named("xrange")
  |
    flowNode = rangeFunction.getACall()
  )
}

/**
 * Determines if a control flow node points to a range/xrange call by name.
 * @param flowNode The control flow node to be checked.
 */
predicate is_named_range_call(ControlFlowNode flowNode) {
  exists(string rangeFunctionName | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = rangeFunctionName |
    rangeFunctionName = "range" or rangeFunctionName = "xrange"
  )
}

/**
 * Determines if a control flow node points to a nested range call.
 * @param flowNode The control flow node to be checked.
 */
predicate is_nested_range_call(ControlFlowNode flowNode) {
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * Determines if a control flow node points to a call to range or xrange.
 * @param flowNode The control flow node to be checked.
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  is_direct_range_call(flowNode)
  or
  is_named_range_call(flowNode)
  or
  is_nested_range_call(flowNode)
}

/**
 * Determines if a name node uses a non-constant variable.
 * @param nameExpression The name node to be checked.
 */
predicate uses_non_constant_variable(Name nameExpression) {
  exists(Variable variable |
    nameExpression.uses(variable) and
    /* The usage is local */
    not nameExpression.getScope() instanceof Module and
    /* The variable is not global */
    not variable.getScope() instanceof Module
  |
    /* The variable is defined multiple times (dynamic) */
    strictcount(Name definition | definition.defines(variable)) > 1
    or
    /* The variable is defined in a for loop */
    exists(For forLoop, Name definition | forLoop.contains(definition) and definition.defines(variable))
    or
    /* The variable is defined in a while loop */
    exists(While whileStmt, Name definition | whileStmt.contains(definition) and definition.defines(variable))
  )
}

/**
 * Determines if the loop body implicitly repeats some operation N times.
 * @param forLoop The for loop to be checked.
 */
predicate is_implicit_repetition(For forLoop) {
  /* The loop body contains only one statement */
  not exists(forLoop.getStmt(1)) and
  /* That statement contains an immutable literal */
  exists(ImmutableLiteral constantLiteral | 
    forLoop.getStmt(0).contains(constantLiteral)) and
  /* Does not contain names that use non-constant variables */
  not exists(Name nameExpression | 
    forLoop.getBody().contains(nameExpression) and uses_non_constant_variable(nameExpression))
}

/**
 * Gets the control flow graph node for the iterable object associated with
 * a for statement in a comprehension.
 * @param comprehensionFor The for statement in the comprehension.
 * @return The control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For comprehensionFor) {
  exists(Comp listComprehension | 
    listComprehension.getFunction().getStmt(0) = comprehensionFor | 
    listComprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines if the variable name is acceptable for an unused variable.
 * @param variable The variable to be checked.
 */
predicate name_acceptable_for_unused_variable(Variable variable) {
  exists(string name | name = variable.getId() and name.matches("_%"))
}

/**
 * Checks if a for loop has an unused iteration variable.
 * @param forLoop The for loop to be checked.
 * @param iterationVar The iteration variable that is unused.
 * @param message The warning message to be displayed.
 */
predicate has_unused_iteration_variable(For forLoop, Variable iterationVar, string message) {
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
  /* Not a trivial loop (empty or single exit) */
  not is_trivial_loop(forLoop) and
  /* Not a counting loop */
  not is_counting_loop(forLoop) and
  /* Not an implicit repetition operation */
  not is_implicit_repetition(forLoop) and
  /* Set different warning messages based on whether the variable is deleted in the loop body */
  if exists(Name deleteStatement | deleteStatement.deletes(iterationVar) and forLoop.getAStmt().contains(deleteStatement))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
}

/**
 * Identifies unused loop iteration variables and generates appropriate warning messages.
 */
from For forLoop, Variable iterationVar, string message
where has_unused_iteration_variable(forLoop, iterationVar, message)
select forLoop, "For loop variable '" + iterationVar.getId() + message