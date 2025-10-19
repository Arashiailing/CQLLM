/**
 * @name Suspicious unused loop iteration variable
 * @description Detects loop iteration variables that are never used, indicating potential logic errors.
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
 * Identifies statements that perform variable increment operations.
 * Covers both augmented assignment (x += n) and binary expression (x = x + n) patterns.
 * @param statement The statement to analyze.
 */
predicate is_increment_operation(Stmt statement) {
  /* Case 1: Augmented assignment with integer literal */
  statement.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Binary expression with self-reference and integer literal */
  exists(Name targetVariable, BinaryExpr additionExpr |
    targetVariable = statement.(AssignStmt).getTarget(0) and
    additionExpr = statement.(AssignStmt).getValue() and
    additionExpr.getLeft().(Name).getVariable() = targetVariable.getVariable() and
    additionExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Identifies counting loops where iteration variables are incremented.
 * @param forLoop The loop to analyze.
 */
predicate is_counting_loop(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * Identifies empty loops containing only a Pass statement.
 * @param forLoop The loop to analyze.
 */
predicate is_empty_loop(For forLoop) { 
  not exists(forLoop.getStmt(1)) and 
  forLoop.getStmt(0) instanceof Pass 
}

/**
 * Identifies loops with only a single exit statement (return/break) and no continue.
 * @param forLoop The loop to analyze.
 */
predicate has_single_exit_statement(For forLoop) {
  not exists(Continue c | forLoop.contains(c)) and
  exists(Stmt lastStatement | lastStatement = forLoop.getBody().getLastItem() |
    lastStatement instanceof Return
    or
    lastStatement instanceof Break
  )
}

/**
 * Identifies control flow nodes representing range/xrange function calls.
 * Handles Python 2/3 compatibility and import variations.
 * @param flowNode The control flow node to analyze.
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* Direct range/xrange calls */
  exists(Value rangeFunction |
    rangeFunction = Value::named("range") or
    rangeFunction = Value::named("xrange")
  |
    flowNode = rangeFunction.getACall()
  )
  or
  /* Named range calls (e.g., from imports) */
  exists(string rangeFuncName | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = rangeFuncName |
    rangeFuncName = "range" or rangeFuncName = "xrange"
  )
  or
  /* Nested range calls (e.g., list(range(...))) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * Identifies name nodes that reference non-constant variables.
 * @param nameNode The name node to analyze.
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable variable |
    nameNode.uses(variable) and
    /* Local usage only */
    not nameNode.getScope() instanceof Module and
    /* Non-global variables */
    not variable.getScope() instanceof Module
  |
    /* Dynamically defined variables */
    strictcount(Name def | def.defines(variable)) > 1
    or
    /* Variables defined in for loops */
    exists(For forLoop, Name def | forLoop.contains(def) and def.defines(variable))
    or
    /* Variables defined in while loops */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(variable))
  )
}

/**
 * Identifies loops performing implicit repetition operations.
 * @param forLoop The loop to analyze.
 */
predicate is_implicit_repetition(For forLoop) {
  /* Single-statement loop body */
  not exists(forLoop.getStmt(1)) and
  /* Contains immutable literal */
  exists(ImmutableLiteral literal | 
    forLoop.getStmt(0).contains(literal)) and
  /* No non-constant variable references */
  not exists(Name nameNode | 
    forLoop.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * Retrieves the iterable object from a comprehension's for statement.
 * @param comprehensionFor The for statement within a comprehension.
 * @return The control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For comprehensionFor) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = comprehensionFor | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if a variable name is acceptable for unused variables (starts with underscore).
 * @param variable The variable to analyze.
 */
predicate name_acceptable_for_unused_variable(Variable variable) {
  exists(string name | name = variable.getId() and name.matches("_%"))
}

/**
 * Detects unused iteration variables in for loops.
 * @param forLoop The loop to analyze.
 * @param iterationVariable The unused iteration variable.
 * @param warningMessage The warning message to display.
 */
predicate has_unused_iteration_variable(For forLoop, Variable iterationVariable, string warningMessage) {
  /* Variable is loop target */
  forLoop.getTarget() = iterationVariable.getAnAccess() and
  /* Variable not referenced in loop body */
  not forLoop.getAStmt().contains(iterationVariable.getAnAccess()) and
  /* Not a range/xrange loop */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* Not a comprehension range/xrange loop */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* Variable name not marked as intentionally unused */
  not name_acceptable_for_unused_variable(iterationVariable) and
  /* Not in generator expression */
  not forLoop.getScope().getName() = "genexpr" and
  /* Not an empty loop */
  not is_empty_loop(forLoop) and
  /* Not single-exit loop */
  not has_single_exit_statement(forLoop) and
  /* Not a counting loop */
  not is_counting_loop(forLoop) and
  /* Not implicit repetition */
  not is_implicit_repetition(forLoop) and
  /* Generate context-specific message */
  if exists(Name deletionNode | deletionNode.deletes(iterationVariable) and forLoop.getAStmt().contains(deletionNode))
  then warningMessage = "' is deleted but never used in the loop body."
  else warningMessage = "' is never used in the loop body."
}

/**
 * Identifies unused loop iteration variables with appropriate warning messages.
 */
from For forLoop, Variable iterationVariable, string warningMessage
where has_unused_iteration_variable(forLoop, iterationVariable, warningMessage)
select forLoop, "For loop variable '" + iterationVariable.getId() + warningMessage