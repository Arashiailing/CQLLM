/**
 * @name Suspicious unused loop iteration variable
 * @description Detects loop iteration variables that are never used, indicating potential errors.
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
 * Identifies increment operations like x += n or x = x + n.
 * @param statement Statement to analyze for increment patterns.
 */
predicate is_increment_operation(Stmt statement) {
  /* Case 1: Augmented assignment (e.g., x += 1) */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Standard assignment with self-increment (e.g., x = x + 1) */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = statement.(AssignStmt).getTarget(0) and
    addExpr = statement.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Checks if a for loop is a counting loop with increment operations.
 * @param loop Loop to analyze for counting patterns.
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * Determines if a for loop contains only a Pass statement.
 * @param loop Loop to check for emptiness.
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * Checks if a for loop contains only a single exit statement (return/break).
 * @param loop Loop to analyze for exit patterns.
 */
predicate has_single_exit_statement(For loop) {
  not exists(Continue c | loop.contains(c)) and
  exists(Stmt finalStmt | finalStmt = loop.getBody().getLastItem() |
    finalStmt instanceof Return
    or
    finalStmt instanceof Break
  )
}

/**
 * Identifies calls to range/xrange functions or classes.
 * @param node Control flow node to analyze.
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* Handle direct range/xrange calls */
  exists(Value rangeFunction |
    rangeFunction = Value::named("range") or
    rangeFunction = Value::named("xrange")
  |
    node = rangeFunction.getACall()
  )
  or
  /* Handle imported range calls (e.g., from six.moves import range) */
  exists(string rangeFuncName | 
    node.getNode().(Call).getFunc().(Name).getId() = rangeFuncName |
    rangeFuncName = "range" or rangeFuncName = "xrange"
  )
  or
  /* Handle nested calls (e.g., list(range(...))) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * Checks if a name node uses non-constant variables.
 * @param nameNode Name node to analyze.
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable variable |
    nameNode.uses(variable) and
    /* Exclude module-level usage */
    not nameNode.getScope() instanceof Module and
    /* Exclude global variables */
    not variable.getScope() instanceof Module
  |
    /* Variable has multiple definitions (dynamic) */
    strictcount(Name def | def.defines(variable)) > 1
    or
    /* Variable defined in a for loop */
    exists(For loop, Name def | loop.contains(def) and def.defines(variable))
    or
    /* Variable defined in a while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(variable))
  )
}

/**
 * Identifies loops that implicitly repeat operations N times.
 * @param loop Loop to analyze for repetition patterns.
 */
predicate is_implicit_repetition(For loop) {
  /* Loop body contains exactly one statement */
  not exists(loop.getStmt(1)) and
  /* Statement contains an immutable literal */
  exists(ImmutableLiteral immutable | 
    loop.getStmt(0).contains(immutable)) and
  /* No non-constant variable usage */
  not exists(Name nameNode | 
    loop.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * Retrieves the iterable object from a comprehension's for statement.
 * @param comprehensionLoop Artificial for statement in a comprehension.
 * @return Control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For comprehensionLoop) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = comprehensionLoop | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if a variable name is acceptable for unused variables (starts with underscore).
 * @param variable Variable to check.
 */
predicate name_acceptable_for_unused_variable(Variable variable) {
  exists(string varName | varName = variable.getId() and varName.matches("_%"))
}

/**
 * Main query to detect unused loop iteration variables.
 */
from For forLoop, Variable iterationVariable, string message
where
  /* Loop target is the iteration variable */
  forLoop.getTarget() = iterationVariable.getAnAccess() and
  /* Variable not used in loop body */
  not forLoop.getAStmt().contains(iterationVariable.getAnAccess()) and
  /* Iterator not a range/xrange call */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* Comprehension iterator not a range/xrange call */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* Variable name not acceptable for unused */
  not name_acceptable_for_unused_variable(iterationVariable) and
  /* Exclude generator expressions */
  not forLoop.getScope().getName() = "genexpr" and
  /* Exclude empty loops */
  not is_empty_loop(forLoop) and
  /* Exclude single-exit loops */
  not has_single_exit_statement(forLoop) and
  /* Exclude counting loops */
  not is_counting_loop(forLoop) and
  /* Exclude implicit repetition loops */
  not is_implicit_repetition(forLoop) and
  /* Generate appropriate warning message */
  if exists(Name delNode | delNode.deletes(iterationVariable) and forLoop.getAStmt().contains(delNode))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
select forLoop, "For loop variable '" + iterationVariable.getId() + message