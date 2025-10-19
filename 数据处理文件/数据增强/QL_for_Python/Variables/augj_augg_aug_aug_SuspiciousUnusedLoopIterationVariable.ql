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
 * @param stmt Statement to analyze for increment patterns.
 */
predicate is_increment_operation(Stmt stmt) {
  /* Case 1: Augmented assignment (e.g., x += 1) */
  stmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Standard assignment with self-increment (e.g., x = x + 1) */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = stmt.(AssignStmt).getTarget(0) and
    addExpr = stmt.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Checks if a for loop is a counting loop with increment operations.
 * @param forLoop Loop to analyze for counting patterns.
 */
predicate is_counting_loop(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * Determines if a for loop contains only a Pass statement.
 * @param forLoop Loop to check for emptiness.
 */
predicate is_empty_loop(For forLoop) { 
  not exists(forLoop.getStmt(1)) and 
  forLoop.getStmt(0) instanceof Pass 
}

/**
 * Checks if a for loop contains only a single exit statement (return/break).
 * @param forLoop Loop to analyze for exit patterns.
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
 * Identifies calls to range/xrange functions or classes.
 * @param cfNode Control flow node to analyze.
 */
predicate is_range_function_call(ControlFlowNode cfNode) {
  /* Handle direct range/xrange calls */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or
    rangeFunc = Value::named("xrange")
  |
    cfNode = rangeFunc.getACall()
  )
  or
  /* Handle imported range calls (e.g., from six.moves import range) */
  exists(string funcName | 
    cfNode.getNode().(Call).getFunc().(Name).getId() = funcName |
    funcName = "range" or funcName = "xrange"
  )
  or
  /* Handle nested calls (e.g., list(range(...))) */
  cfNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(cfNode.(CallNode).getArg(0))
}

/**
 * Checks if a name node uses non-constant variables.
 * @param name Name node to analyze.
 */
predicate uses_non_constant_variable(Name name) {
  exists(Variable var |
    name.uses(var) and
    /* Exclude module-level usage */
    not name.getScope() instanceof Module and
    /* Exclude global variables */
    not var.getScope() instanceof Module
  |
    /* Variable has multiple definitions (dynamic) */
    strictcount(Name defNode | defNode.defines(var)) > 1
    or
    /* Variable defined in a for loop */
    exists(For loop, Name defNode | loop.contains(defNode) and defNode.defines(var))
    or
    /* Variable defined in a while loop */
    exists(While whileLoop, Name defNode | whileLoop.contains(defNode) and defNode.defines(var))
  )
}

/**
 * Identifies loops that implicitly repeat operations N times.
 * @param forLoop Loop to analyze for repetition patterns.
 */
predicate is_implicit_repetition(For forLoop) {
  /* Loop body contains exactly one statement */
  not exists(forLoop.getStmt(1)) and
  /* Statement contains an immutable literal */
  exists(ImmutableLiteral literal | 
    forLoop.getStmt(0).contains(literal)) and
  /* No non-constant variable usage */
  not exists(Name name | 
    forLoop.getBody().contains(name) and uses_non_constant_variable(name))
}

/**
 * Retrieves the iterable object from a comprehension's for statement.
 * @param compLoop Artificial for statement in a comprehension.
 * @return Control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For compLoop) {
  exists(Comp comp | 
    comp.getFunction().getStmt(0) = compLoop | 
    comp.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if a variable name is acceptable for unused variables (starts with underscore).
 * @param var Variable to check.
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string varName | varName = var.getId() and varName.matches("_%"))
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