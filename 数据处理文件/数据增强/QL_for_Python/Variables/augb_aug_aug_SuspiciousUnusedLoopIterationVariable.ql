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
 * @param operation The statement to analyze.
 */
predicate represents_increment_operation(Stmt operation) {
  /* Case 1: Augmented assignment with integer literal */
  operation.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Standard assignment with addition pattern */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = operation.(AssignStmt).getTarget(0) and
    addExpr = operation.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Identifies counting loops where iteration variable is incremented.
 * @param loop The for loop to examine.
 */
predicate is_counting_loop(For loop) { 
  represents_increment_operation(loop.getAStmt()) 
}

/**
 * Identifies empty loops containing only a Pass statement.
 * @param loop The for loop to examine.
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * Identifies loops with a single exit statement (return/break) and no continues.
 * @param loop The for loop to examine.
 */
predicate has_single_exit_statement(For loop) {
  not exists(Continue c | loop.contains(c)) and
  exists(Stmt lastStmt | lastStmt = loop.getBody().getLastItem() |
    lastStmt instanceof Return or lastStmt instanceof Break
  )
}

/**
 * Identifies calls to range/xrange functions or classes.
 * @param node The control flow node to analyze.
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* Direct range/xrange references */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or rangeFunc = Value::named("xrange")
  |
    node = rangeFunc.getACall()
  )
  or
  /* Named range/xrange calls */
  exists(string rangeName | 
    node.getNode().(Call).getFunc().(Name).getId() = rangeName |
    rangeName = "range" or rangeName = "xrange"
  )
  or
  /* Nested calls like list(range(...)) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * Identifies name nodes using non-constant variables.
 * @param nameNode The name expression to analyze.
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable var |
    nameNode.uses(var) and
    /* Local scope usage */
    not nameNode.getScope() instanceof Module and
    /* Non-global variable */
    not var.getScope() instanceof Module
  |
    /* Dynamically defined variable */
    strictcount(Name def | def.defines(var)) > 1
    or
    /* Variable defined in for loop */
    exists(For loop, Name def | loop.contains(def) and def.defines(var))
    or
    /* Variable defined in while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * Identifies loops that implicitly repeat operations N times.
 * @param loop The for loop to examine.
 */
predicate is_implicit_repetition(For loop) {
  /* Single statement loop body */
  not exists(loop.getStmt(1)) and
  /* Contains immutable literal */
  exists(ImmutableLiteral literal | loop.getStmt(0).contains(literal)) and
  /* No non-constant variable usage */
  not exists(Name nameExpr | 
    loop.getBody().contains(nameExpr) and uses_non_constant_variable(nameExpr))
}

/**
 * Retrieves the iterable object from a comprehension's for statement.
 * @param comprehensionFor The artificial for statement in comprehension.
 * @return The iterable's control flow node.
 */
ControlFlowNode get_comprehension_iterable(For comprehensionFor) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = comprehensionFor | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if variable name is acceptable for unused status (starts with underscore).
 * @param var The variable to check.
 */
predicate is_unused_variable_name_acceptable(Variable var) {
  exists(string name | name = var.getId() and name.matches("_%"))
}

/**
 * Detects unused loop iteration variables with contextual warnings.
 */
from For targetLoop, Variable iterVar, string warningMessage
where
  /* Iteration variable identification */
  targetLoop.getTarget() = iterVar.getAnAccess() and
  /* No usage in loop body */
  not targetLoop.getAStmt().contains(iterVar.getAnAccess()) and
  /* Non-range iterator */
  not is_range_function_call(targetLoop.getIter().getAFlowNode()) and
  /* Non-range comprehension iterator */
  not is_range_function_call(get_comprehension_iterable(targetLoop)) and
  /* Unacceptable variable name */
  not is_unused_variable_name_acceptable(iterVar) and
  /* Not generator expression */
  not targetLoop.getScope().getName() = "genexpr" and
  /* Exclusion patterns */
  not is_empty_loop(targetLoop) and
  not has_single_exit_statement(targetLoop) and
  not is_counting_loop(targetLoop) and
  not is_implicit_repetition(targetLoop) and
  /* Contextual warning message */
  if exists(Name delNode | delNode.deletes(iterVar) and targetLoop.getAStmt().contains(delNode))
  then warningMessage = "' is deleted, but not used, in the loop body."
  else warningMessage = "' is not used in the loop body."
select targetLoop, "For loop variable '" + iterVar.getId() + warningMessage