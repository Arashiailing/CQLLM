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
 * Identifies increment operations like x += n or x = x + n.
 * @param stmt The statement to analyze.
 */
predicate represents_increment_operation(Stmt stmt) {
  /* Augmented assignment with integer literal */
  stmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Standard assignment with addition pattern */
  exists(Name targetName, BinaryExpr additionExpr |
    targetName = stmt.(AssignStmt).getTarget(0) and
    additionExpr = stmt.(AssignStmt).getValue() and
    additionExpr.getLeft().(Name).getVariable() = targetName.getVariable() and
    additionExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Identifies calls to range/xrange functions or classes.
 * @param flowNode The control flow node to analyze.
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* Direct range/xrange references */
  exists(Value rangeValue |
    rangeValue = Value::named("range") or rangeValue = Value::named("xrange")
  |
    flowNode = rangeValue.getACall()
  )
  or
  /* Named range/xrange calls */
  exists(string rangeFuncName | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = rangeFuncName |
    rangeFuncName = "range" or rangeFuncName = "xrange"
  )
  or
  /* Nested calls like list(range(...)) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * Identifies name nodes using non-constant variables.
 * @param varName The name expression to analyze.
 */
predicate uses_non_constant_variable(Name varName) {
  exists(Variable variable |
    varName.uses(variable) and
    /* Local scope usage */
    not varName.getScope() instanceof Module and
    /* Non-global variable */
    not variable.getScope() instanceof Module
  |
    /* Dynamically defined variable */
    strictcount(Name defNode | defNode.defines(variable)) > 1
    or
    /* Variable defined in for loop */
    exists(For forLoop, Name defNode | forLoop.contains(defNode) and defNode.defines(variable))
    or
    /* Variable defined in while loop */
    exists(While whileStmt, Name defNode | whileStmt.contains(defNode) and defNode.defines(variable))
  )
}

/**
 * Identifies counting loops where iteration variable is incremented.
 * @param forLoop The for loop to examine.
 */
predicate is_counting_loop(For forLoop) { 
  represents_increment_operation(forLoop.getAStmt()) 
}

/**
 * Identifies empty loops containing only a Pass statement.
 * @param forLoop The for loop to examine.
 */
predicate is_empty_loop(For forLoop) { 
  not exists(forLoop.getStmt(1)) and 
  forLoop.getStmt(0) instanceof Pass 
}

/**
 * Identifies loops with a single exit statement (return/break) and no continues.
 * @param forLoop The for loop to examine.
 */
predicate has_single_exit_statement(For forLoop) {
  not exists(Continue continueStmt | forLoop.contains(continueStmt)) and
  exists(Stmt finalStmt | finalStmt = forLoop.getBody().getLastItem() |
    finalStmt instanceof Return or finalStmt instanceof Break
  )
}

/**
 * Identifies loops that implicitly repeat operations N times.
 * @param forLoop The for loop to examine.
 */
predicate is_implicit_repetition(For forLoop) {
  /* Single statement loop body */
  not exists(forLoop.getStmt(1)) and
  /* Contains immutable literal */
  exists(ImmutableLiteral immutableLiteral | forLoop.getStmt(0).contains(immutableLiteral)) and
  /* No non-constant variable usage */
  not exists(Name varExpr | 
    forLoop.getBody().contains(varExpr) and uses_non_constant_variable(varExpr))
}

/**
 * Retrieves the iterable object from a comprehension's for statement.
 * @param compForStmt The artificial for statement in comprehension.
 * @return The iterable's control flow node.
 */
ControlFlowNode get_comprehension_iterable(For compForStmt) {
  exists(Comp comp | 
    comp.getFunction().getStmt(0) = compForStmt | 
    comp.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if variable name is acceptable for unused status (starts with underscore).
 * @param variable The variable to check.
 */
predicate is_unused_variable_name_acceptable(Variable variable) {
  exists(string varName | varName = variable.getId() and varName.matches("_%"))
}

/**
 * Detects unused loop iteration variables with contextual warnings.
 */
from For forStmt, Variable iterationVar, string msg
where
  /* Iteration variable identification */
  forStmt.getTarget() = iterationVar.getAnAccess() and
  /* No usage in loop body */
  not forStmt.getAStmt().contains(iterationVar.getAnAccess()) and
  /* Non-range iterator */
  not is_range_function_call(forStmt.getIter().getAFlowNode()) and
  /* Non-range comprehension iterator */
  not is_range_function_call(get_comprehension_iterable(forStmt)) and
  /* Unacceptable variable name */
  not is_unused_variable_name_acceptable(iterationVar) and
  /* Not generator expression */
  not forStmt.getScope().getName() = "genexpr" and
  /* Exclusion patterns */
  not is_empty_loop(forStmt) and
  not has_single_exit_statement(forStmt) and
  not is_counting_loop(forStmt) and
  not is_implicit_repetition(forStmt) and
  /* Contextual warning message */
  if exists(Name deleteNode | deleteNode.deletes(iterationVar) and forStmt.getAStmt().contains(deleteNode))
  then msg = "' is deleted, but not used, in the loop body."
  else msg = "' is not used in the loop body."
select forStmt, "For loop variable '" + iterationVar.getId() + msg