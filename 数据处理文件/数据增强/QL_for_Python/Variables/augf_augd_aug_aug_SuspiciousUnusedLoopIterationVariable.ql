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
 * Determines if the statement represents an increment operation (e.g., x += n or x = x + n).
 * @param incrementOp The statement to be checked.
 */
predicate is_increment_operation(Stmt incrementOp) {
  /* Case 1: Augmented assignment with integer literal */
  incrementOp.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Binary assignment with integer literal */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = incrementOp.(AssignStmt).getTarget(0) and
    addExpr = incrementOp.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Identifies counting loops where iteration variables are incremented.
 * @param loop The for loop to be checked.
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * Identifies empty loops containing only a Pass statement.
 * @param loop The for loop to be checked.
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * Identifies loops with a single exit statement (return/break) and no continue statements.
 * @param loop The for loop to be checked.
 */
predicate has_single_exit_statement(For loop) {
  not exists(Continue c | loop.contains(c)) and
  exists(Stmt lastStmt | lastStmt = loop.getBody().getLastItem() |
    lastStmt instanceof Return
    or
    lastStmt instanceof Break
  )
}

/**
 * Determines if a control flow node represents a range/xrange function call.
 * @param flowNode The control flow node to be checked.
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* Handle direct range/xrange calls */
  exists(Value rangeOrXrange |
    rangeOrXrange = Value::named("range") or
    rangeOrXrange = Value::named("xrange")
  |
    flowNode = rangeOrXrange.getACall()
  )
  or
  /* Handle imported range/xrange calls */
  exists(string funcName | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = funcName |
    funcName = "range" or funcName = "xrange"
  )
  or
  /* Handle nested calls like list(range(...)) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * Determines if a name node references a non-constant variable.
 * @param name The name node to be checked.
 */
predicate uses_non_constant_variable(Name name) {
  exists(Variable variable |
    name.uses(variable) and
    /* Local usage check */
    not name.getScope() instanceof Module and
    /* Non-global variable check */
    not variable.getScope() instanceof Module
  |
    /* Multi-definition check */
    strictcount(Name def | def.defines(variable)) > 1
    or
    /* For-loop definition check */
    exists(For forLoop, Name def | forLoop.contains(def) and def.defines(variable))
    or
    /* While-loop definition check */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(variable))
  )
}

/**
 * Identifies loops that implicitly repeat operations N times (e.g., queue.add(None)).
 * @param forLoop The for loop to be checked.
 */
predicate is_implicit_repetition(For forLoop) {
  /* Single-statement loop body */
  not exists(forLoop.getStmt(1)) and
  /* Contains immutable literal */
  exists(ImmutableLiteral literal | 
    forLoop.getStmt(0).contains(literal)) and
  /* No non-constant variable references */
  not exists(Name name | 
    forLoop.getBody().contains(name) and uses_non_constant_variable(name))
}

/**
 * Retrieves the iterable control flow node from a comprehension's for statement.
 * For example, in `{ y for y in x }`, return the node for `x`.
 * @param forStmt The for statement in the comprehension.
 * @return The control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For forStmt) {
  exists(Comp comp | 
    comp.getFunction().getStmt(0) = forStmt | 
    comp.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Determines if a variable name is acceptable for unused variables (starts with underscore).
 * @param variable The variable to be checked.
 */
predicate name_acceptable_for_unused_variable(Variable variable) {
  exists(string name | name = variable.getId() and name.matches("_%"))
}

/**
 * Detects unused loop iteration variables and generates warning messages.
 */
from For forLoop, Variable iterationVar, string message
where
  /* Identify iteration variable */
  forLoop.getTarget() = iterationVar.getAnAccess() and
  /* Variable not referenced in loop body */
  not forLoop.getAStmt().contains(iterationVar.getAnAccess()) and
  /* Not a range-based loop */
  not is_range_function_call(forLoop.getIter().getAFlowNode()) and
  /* Not a range-based comprehension */
  not is_range_function_call(get_comprehension_iterable(forLoop)) and
  /* Variable name not acceptable for unused */
  not name_acceptable_for_unused_variable(iterationVar) and
  /* Not in generator expression */
  not forLoop.getScope().getName() = "genexpr" and
  /* Not an empty loop */
  not is_empty_loop(forLoop) and
  /* Not a single-exit loop */
  not has_single_exit_statement(forLoop) and
  /* Not a counting loop */
  not is_counting_loop(forLoop) and
  /* Not implicit repetition */
  not is_implicit_repetition(forLoop) and
  /* Generate appropriate message */
  if exists(Name delStmt | delStmt.deletes(iterationVar) and forLoop.getAStmt().contains(delStmt))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
select forLoop, "For loop variable '" + iterationVar.getId() + message