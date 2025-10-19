/**
 * @name Suspicious unused loop iteration variable
 * @description Detects loop iteration variables that are declared but never used within the loop body.
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
 * Determines if a statement performs an increment operation (e.g., x += n or x = x + n).
 * @param examinedStmt The statement being analyzed for increment patterns.
 */
predicate represents_increment_operation(Stmt examinedStmt) {
  /* Handles augmented assignment with integer literal (e.g., counter += 1) */
  examinedStmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Handles standard assignment with addition pattern (e.g., counter = counter + 1) */
  exists(Name varRef, BinaryExpr additionExpr |
    varRef = examinedStmt.(AssignStmt).getTarget(0) and
    additionExpr = examinedStmt.(AssignStmt).getValue() and
    additionExpr.getLeft().(Name).getVariable() = varRef.getVariable() and
    additionExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Detects counting loops where the iteration variable is directly incremented.
 * @param targetLoop The for loop being analyzed.
 */
predicate is_counting_loop(For targetLoop) { 
  represents_increment_operation(targetLoop.getAStmt()) 
}

/**
 * Finds empty loops that contain only a Pass statement.
 * @param targetLoop The for loop being evaluated.
 */
predicate is_empty_loop(For targetLoop) { 
  not exists(targetLoop.getStmt(1)) and 
  targetLoop.getStmt(0) instanceof Pass 
}

/**
 * Identifies loops with a single exit point (return/break) and no continue statements.
 * @param targetLoop The for loop being inspected.
 */
predicate has_single_exit_statement(For targetLoop) {
  not exists(Continue continueStmt | targetLoop.contains(continueStmt)) and
  exists(Stmt finalStmt | finalStmt = targetLoop.getBody().getLastItem() |
    finalStmt instanceof Return or finalStmt instanceof Break
  )
}

/**
 * Recognizes calls to range/xrange functions or classes in various forms.
 * @param node The control flow node being evaluated.
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* Direct range/xrange function references */
  exists(Value rangeVal |
    rangeVal = Value::named("range") or rangeVal = Value::named("xrange")
  |
    node = rangeVal.getACall()
  )
  or
  /* Named range/xrange function invocations */
  exists(string funcName | 
    node.getNode().(Call).getFunc().(Name).getId() = funcName |
    funcName = "range" or funcName = "xrange"
  )
  or
  /* Nested calls such as list(range(...)) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * Finds name expressions that reference non-constant variables.
 * @param nameExpr The name expression being evaluated.
 */
predicate uses_non_constant_variable(Name nameExpr) {
  exists(Variable referencedVar |
    nameExpr.uses(referencedVar) and
    /* Local scope usage */
    not nameExpr.getScope() instanceof Module and
    /* Non-global variable */
    not referencedVar.getScope() instanceof Module
  |
    /* Dynamically defined variable (multiple definitions) */
    strictcount(Name defNode | defNode.defines(referencedVar)) > 1
    or
    /* Variable defined within a for loop */
    exists(For enclosingLoop, Name defNode | enclosingLoop.contains(defNode) and defNode.defines(referencedVar))
    or
    /* Variable defined within a while loop */
    exists(While enclosingLoop, Name defNode | enclosingLoop.contains(defNode) and defNode.defines(referencedVar))
  )
}

/**
 * Identifies loops that implicitly repeat operations a fixed number of times.
 * @param targetLoop The for loop being evaluated.
 */
predicate is_implicit_repetition(For targetLoop) {
  /* Single statement loop body */
  not exists(targetLoop.getStmt(1)) and
  /* Contains an immutable literal */
  exists(ImmutableLiteral literal | targetLoop.getStmt(0).contains(literal)) and
  /* No usage of non-constant variables */
  not exists(Name varRef | 
    targetLoop.getBody().contains(varRef) and uses_non_constant_variable(varRef))
}

/**
 * Extracts the iterable object from a comprehension's synthetic for statement.
 * @param compFor The synthetic for statement within a comprehension.
 * @return The control flow node representing the iterable.
 */
ControlFlowNode get_comprehension_iterable(For compFor) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = compFor | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if a variable name follows the convention for intentionally unused variables (starts with underscore).
 * @param targetVar The variable being verified.
 */
predicate is_unused_variable_name_acceptable(Variable targetVar) {
  exists(string varName | varName = targetVar.getId() and varName.matches("_%"))
}

/**
 * Main query for detecting unused loop iteration variables with contextual warning messages.
 */
from For targetLoop, Variable iterationVar, string warningMsg
where
  /* Identify the iteration variable */
  targetLoop.getTarget() = iterationVar.getAnAccess() and
  /* Verify the variable is not used within the loop body */
  not targetLoop.getAStmt().contains(iterationVar.getAnAccess()) and
  /* Exclude range-based iterators */
  not is_range_function_call(targetLoop.getIter().getAFlowNode()) and
  /* Exclude range-based comprehension iterators */
  not is_range_function_call(get_comprehension_iterable(targetLoop)) and
  /* Exclude variables with acceptable unused naming convention */
  not is_unused_variable_name_acceptable(iterationVar) and
  /* Exclude generator expressions */
  not targetLoop.getScope().getName() = "genexpr" and
  /* Apply exclusion patterns for specific loop types */
  not is_empty_loop(targetLoop) and
  not has_single_exit_statement(targetLoop) and
  not is_counting_loop(targetLoop) and
  not is_implicit_repetition(targetLoop) and
  /* Generate contextual warning message based on deletion status */
  if exists(Name deletionStmt | deletionStmt.deletes(iterationVar) and targetLoop.getAStmt().contains(deletionStmt))
  then warningMsg = "' is deleted, but not used, in the loop body."
  else warningMsg = "' is not used in the loop body."
select targetLoop, "For loop variable '" + iterationVar.getId() + warningMsg