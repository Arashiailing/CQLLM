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
 * Detects statements that perform increment operations (e.g., x += n or x = x + n).
 * @param stmtToAnalyze The statement to be analyzed for increment patterns.
 */
predicate represents_increment_operation(Stmt stmtToAnalyze) {
  /* Handles augmented assignment with integer literal (e.g., counter += 1) */
  stmtToAnalyze.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Handles standard assignment with addition pattern (e.g., counter = counter + 1) */
  exists(Name targetName, BinaryExpr additionExpr |
    targetName = stmtToAnalyze.(AssignStmt).getTarget(0) and
    additionExpr = stmtToAnalyze.(AssignStmt).getValue() and
    additionExpr.getLeft().(Name).getVariable() = targetName.getVariable() and
    additionExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Identifies counting loops where the iteration variable is explicitly incremented.
 * @param targetLoop The for loop to be examined.
 */
predicate is_counting_loop(For targetLoop) { 
  represents_increment_operation(targetLoop.getAStmt()) 
}

/**
 * Detects empty loops that contain only a Pass statement.
 * @param targetLoop The for loop to be examined.
 */
predicate is_empty_loop(For targetLoop) { 
  not exists(targetLoop.getStmt(1)) and 
  targetLoop.getStmt(0) instanceof Pass 
}

/**
 * Identifies loops with a single exit point (return/break) and no continue statements.
 * @param targetLoop The for loop to be examined.
 */
predicate has_single_exit_statement(For targetLoop) {
  not exists(Continue c | targetLoop.contains(c)) and
  exists(Stmt finalStmt | finalStmt = targetLoop.getBody().getLastItem() |
    finalStmt instanceof Return or finalStmt instanceof Break
  )
}

/**
 * Detects calls to range/xrange functions or classes in various forms.
 * @param cfNode The control flow node to be analyzed.
 */
predicate is_range_function_call(ControlFlowNode cfNode) {
  /* Direct range/xrange function references */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or rangeFunc = Value::named("xrange")
  |
    cfNode = rangeFunc.getACall()
  )
  or
  /* Named range/xrange function calls */
  exists(string rangeFuncName | 
    cfNode.getNode().(Call).getFunc().(Name).getId() = rangeFuncName |
    rangeFuncName = "range" or rangeFuncName = "xrange"
  )
  or
  /* Nested calls like list(range(...)) */
  cfNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(cfNode.(CallNode).getArg(0))
}

/**
 * Identifies name expressions that reference non-constant variables.
 * @param nameExpr The name expression to be analyzed.
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
    exists(While enclosingWhile, Name defNode | enclosingWhile.contains(defNode) and defNode.defines(referencedVar))
  )
}

/**
 * Detects loops that implicitly repeat operations a fixed number of times.
 * @param targetLoop The for loop to be examined.
 */
predicate is_implicit_repetition(For targetLoop) {
  /* Single statement loop body */
  not exists(targetLoop.getStmt(1)) and
  /* Contains an immutable literal */
  exists(ImmutableLiteral literal | targetLoop.getStmt(0).contains(literal)) and
  /* No usage of non-constant variables */
  not exists(Name nameExpr | 
    targetLoop.getBody().contains(nameExpr) and uses_non_constant_variable(nameExpr))
}

/**
 * Extracts the iterable object from a comprehension's artificial for statement.
 * @param comprehensionForStmt The artificial for statement within a comprehension.
 * @return The control flow node representing the iterable.
 */
ControlFlowNode get_comprehension_iterable(For comprehensionForStmt) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = comprehensionForStmt | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if a variable name follows the convention for intentionally unused variables (starts with underscore).
 * @param targetVar The variable to be checked.
 */
predicate is_unused_variable_name_acceptable(Variable targetVar) {
  exists(string varName | varName = targetVar.getId() and varName.matches("_%"))
}

/**
 * Main query to detect unused loop iteration variables with contextual warning messages.
 */
from For targetLoop, Variable iterVar, string warningMessage
where
  /* Identify the iteration variable */
  targetLoop.getTarget() = iterVar.getAnAccess() and
  /* Confirm the variable is not used within the loop body */
  not targetLoop.getAStmt().contains(iterVar.getAnAccess()) and
  /* Exclude range-based iterators */
  not is_range_function_call(targetLoop.getIter().getAFlowNode()) and
  /* Exclude range-based comprehension iterators */
  not is_range_function_call(get_comprehension_iterable(targetLoop)) and
  /* Exclude variables with acceptable unused naming convention */
  not is_unused_variable_name_acceptable(iterVar) and
  /* Exclude generator expressions */
  not targetLoop.getScope().getName() = "genexpr" and
  /* Apply exclusion patterns for specific loop types */
  not is_empty_loop(targetLoop) and
  not has_single_exit_statement(targetLoop) and
  not is_counting_loop(targetLoop) and
  not is_implicit_repetition(targetLoop) and
  /* Generate contextual warning message based on deletion status */
  if exists(Name delNode | delNode.deletes(iterVar) and targetLoop.getAStmt().contains(delNode))
  then warningMessage = "' is deleted, but not used, in the loop body."
  else warningMessage = "' is not used in the loop body."
select targetLoop, "For loop variable '" + iterVar.getId() + warningMessage