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
 * Identifies whether a statement represents a variable increment operation,
 * such as x += n or x = x + n.
 * @param statement The statement to be examined.
 */
predicate is_increment_operation(Stmt statement) {
  /* Case 1: Increment in the form x += n */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Increment in the form x = x + n */
  exists(Name targetVariable, BinaryExpr additionExpr |
    targetVariable = statement.(AssignStmt).getTarget(0) and
    additionExpr = statement.(AssignStmt).getValue() and
    additionExpr.getLeft().(Name).getVariable() = targetVariable.getVariable() and
    additionExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Determines if the provided for loop is a counting loop,
 * where the iteration variable is incremented in each iteration.
 * @param loopStmt The for loop to be examined.
 */
predicate is_counting_loop(For loopStmt) { 
  is_increment_operation(loopStmt.getAStmt()) 
}

/**
 * Checks if the provided for loop is an empty loop,
 * containing only a Pass statement.
 * @param loopStmt The for loop to be examined.
 */
predicate is_empty_loop(For loopStmt) { 
  not exists(loopStmt.getStmt(1)) and 
  loopStmt.getStmt(0) instanceof Pass 
}

/**
 * Determines if the provided for loop contains only a single exit statement
 * (return or break) without any continue statements.
 * @param loopStmt The for loop to be examined.
 */
predicate has_single_exit_statement(For loopStmt) {
  not exists(Continue c | loopStmt.contains(c)) and
  exists(Stmt lastStmt | lastStmt = loopStmt.getBody().getLastItem() |
    lastStmt instanceof Return
    or
    lastStmt instanceof Break
  )
}

/**
 * Checks if the control flow node refers to a call to range or xrange.
 * @param flowNode The control flow node to be examined.
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* In Python 2, range/xrange are functions, in Python 3 they are classes,
     so they need to be handled as regular objects */
  exists(Value rangeFunction |
    rangeFunction = Value::named("range") or
    rangeFunction = Value::named("xrange")
  |
    flowNode = rangeFunction.getACall()
  )
  or
  /* Handle cases like 'from six.moves import range' that may cause
     pointer analysis failures */
  exists(string rangeFunctionName | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = rangeFunctionName |
    rangeFunctionName = "range" or rangeFunctionName = "xrange"
  )
  or
  /* Handle nested calls like list(range(...)) and list(list(range(...))) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * Determines if the name node uses a non-constant variable.
 * @param nameNode The name node to be examined.
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
    exists(For loopStmt, Name def | loopStmt.contains(def) and def.defines(var))
    or
    /* The variable is defined in a while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * Determines if the loop body implicitly repeats some operation N times.
 * For example: queue.add(None)
 * @param loopStmt The for loop to be examined.
 */
predicate is_implicit_repetition(For loopStmt) {
  /* The loop body contains only one statement */
  not exists(loopStmt.getStmt(1)) and
  /* That statement contains an immutable literal */
  exists(ImmutableLiteral constantLiteral | 
    loopStmt.getStmt(0).contains(constantLiteral)) and
  /* Does not contain names that use non-constant variables */
  not exists(Name nameNode | 
    loopStmt.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * Retrieves the control flow graph node for the iterable object associated with
 * a for statement in a comprehension. The for statement `comprehensionLoop`
 * is an artificial for statement in the comprehension. The result is the
 * iterable in that comprehension.
 * For example: from `{ y for y in x }` get `x`
 * @param comprehensionLoop The for statement in the comprehension.
 * @return The control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For comprehensionLoop) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = comprehensionLoop | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines if the variable name is acceptable for an unused variable
 * (starts with an underscore).
 * @param var The variable to be examined.
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string name | name = var.getId() and name.matches("_%"))
}

/**
 * Identifies unused loop iteration variables and generates appropriate warning messages.
 */
from For loopStmt, Variable loopVar, string warningMsg
where
  /* The loop target variable is loopVar */
  loopStmt.getTarget() = loopVar.getAnAccess() and
  /* The loop increment statement does not contain loopVar */
  not loopStmt.getAStmt().contains(loopVar.getAnAccess()) and
  /* The loop iterator is not a call to range or xrange */
  not is_range_function_call(loopStmt.getIter().getAFlowNode()) and
  /* The iterator in comprehensions is also not a call to range or xrange */
  not is_range_function_call(get_comprehension_iterable(loopStmt)) and
  /* The name of loopVar is not acceptable for an unused variable */
  not name_acceptable_for_unused_variable(loopVar) and
  /* Not in a generator expression */
  not loopStmt.getScope().getName() = "genexpr" and
  /* Not an empty loop */
  not is_empty_loop(loopStmt) and
  /* Does not contain only a single exit statement */
  not has_single_exit_statement(loopStmt) and
  /* Not a counting loop */
  not is_counting_loop(loopStmt) and
  /* Not an implicit repetition operation */
  not is_implicit_repetition(loopStmt) and
  /* Set different warning messages based on whether the variable is deleted in the loop body */
  if exists(Name deleteNode | deleteNode.deletes(loopVar) and loopStmt.getAStmt().contains(deleteNode))
  then warningMsg = "' is deleted, but not used, in the loop body."
  else warningMsg = "' is not used in the loop body."
select loopStmt, "For loop variable '" + loopVar.getId() + warningMsg