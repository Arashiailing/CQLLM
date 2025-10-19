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
 * Identifies statements that execute increment operations (such as x += n or x = x + n).
 * @param stmtToCheck The statement to be examined for increment patterns.
 */
predicate represents_increment_operation(Stmt stmtToCheck) {
  /* Processes augmented assignment with integer literal (e.g., counter += 1) */
  stmtToCheck.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Processes standard assignment with addition pattern (e.g., counter = counter + 1) */
  exists(Name varName, BinaryExpr addExpr |
    varName = stmtToCheck.(AssignStmt).getTarget(0) and
    addExpr = stmtToCheck.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = varName.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Recognizes counting loops in which the iteration variable is directly incremented.
 * @param loopToExamine The for loop to be analyzed.
 */
predicate is_counting_loop(For loopToExamine) { 
  represents_increment_operation(loopToExamine.getAStmt()) 
}

/**
 * Identifies empty loops that solely contain a Pass statement.
 * @param loopToCheck The for loop to be evaluated.
 */
predicate is_empty_loop(For loopToCheck) { 
  not exists(loopToCheck.getStmt(1)) and 
  loopToCheck.getStmt(0) instanceof Pass 
}

/**
 * Discovers loops featuring a single exit point (return/break) without continue statements.
 * @param loopToAnalyze The for loop to be inspected.
 */
predicate has_single_exit_statement(For loopToAnalyze) {
  not exists(Continue contStmt | loopToAnalyze.contains(contStmt)) and
  exists(Stmt lastStmt | lastStmt = loopToAnalyze.getBody().getLastItem() |
    lastStmt instanceof Return or lastStmt instanceof Break
  )
}

/**
 * Recognizes invocations of range/xrange functions or classes in multiple formats.
 * @param flowNode The control flow node to be evaluated.
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* Direct range/xrange function references */
  exists(Value rangeValue |
    rangeValue = Value::named("range") or rangeValue = Value::named("xrange")
  |
    flowNode = rangeValue.getACall()
  )
  or
  /* Named range/xrange function invocations */
  exists(string rangeFuncId | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = rangeFuncId |
    rangeFuncId = "range" or rangeFuncId = "xrange"
  )
  or
  /* Nested invocations such as list(range(...)) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * Discovers name expressions that refer to non-constant variables.
 * @param nameRef The name expression to be evaluated.
 */
predicate uses_non_constant_variable(Name nameRef) {
  exists(Variable usedVar |
    nameRef.uses(usedVar) and
    /* Local scope usage */
    not nameRef.getScope() instanceof Module and
    /* Non-global variable */
    not usedVar.getScope() instanceof Module
  |
    /* Dynamically defined variable (multiple definitions) */
    strictcount(Name defNode | defNode.defines(usedVar)) > 1
    or
    /* Variable defined within a for loop */
    exists(For forLoop, Name defNode | forLoop.contains(defNode) and defNode.defines(usedVar))
    or
    /* Variable defined within a while loop */
    exists(While whileLoop, Name defNode | whileLoop.contains(defNode) and defNode.defines(usedVar))
  )
}

/**
 * Identifies loops that implicitly repeat operations a predetermined number of times.
 * @param loopToInspect The for loop to be evaluated.
 */
predicate is_implicit_repetition(For loopToInspect) {
  /* Single statement loop body */
  not exists(loopToInspect.getStmt(1)) and
  /* Contains an immutable literal */
  exists(ImmutableLiteral immutLiteral | loopToInspect.getStmt(0).contains(immutLiteral)) and
  /* No usage of non-constant variables */
  not exists(Name varRef | 
    loopToInspect.getBody().contains(varRef) and uses_non_constant_variable(varRef))
}

/**
 * Retrieves the iterable object from a comprehension's synthetic for statement.
 * @param compForStmt The synthetic for statement within a comprehension.
 * @return The control flow node representing the iterable.
 */
ControlFlowNode get_comprehension_iterable(For compForStmt) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = compForStmt | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Verifies if a variable name adheres to the convention for intentionally unused variables (begins with underscore).
 * @param varToCheck The variable to be verified.
 */
predicate is_unused_variable_name_acceptable(Variable varToCheck) {
  exists(string identifier | identifier = varToCheck.getId() and identifier.matches("_%"))
}

/**
 * Primary query for identifying unused loop iteration variables with contextual warning messages.
 */
from For forLoop, Variable loopVar, string alertMessage
where
  /* Identify the iteration variable */
  forLoop.getTarget() = loopVar.getAnAccess() and
  /* Confirm the variable is not utilized within the loop body */
  not forLoop.getAStmt().contains(loopVar.getAnAccess()) and
  /* Exclude range-based iterators */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* Exclude range-based comprehension iterators */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* Exclude variables with acceptable unused naming convention */
  not is_unused_variable_name_acceptable(loopVar) and
  /* Exclude generator expressions */
  not forLoop.getScope().getName() = "genexpr" and
  /* Apply exclusion patterns for specific loop types */
  not is_empty_loop(forLoop) and
  not has_single_exit_statement(forLoop) and
  not is_counting_loop(forLoop) and
  not is_implicit_repetition(forLoop) and
  /* Generate contextual warning message based on deletion status */
  if exists(Name delStmt | delStmt.deletes(loopVar) and forLoop.getAStmt().contains(delStmt))
  then alertMessage = "' is deleted, but not used, in the loop body."
  else alertMessage = "' is not used in the loop body."
select forLoop, "For loop variable '" + loopVar.getId() + alertMessage