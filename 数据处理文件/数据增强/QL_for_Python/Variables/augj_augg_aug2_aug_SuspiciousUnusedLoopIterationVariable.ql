/**
 * @name Suspicious unused loop iteration variable
 * @description Detects loop iteration variables that are never used, which often indicates programming errors
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
 * Identifies variable increment operations (e.g., x += n or x = x + n)
 * @param stmt The statement to be analyzed
 */
predicate is_increment_operation(Stmt stmt) {
  /* Case 1: Augmented assignment with integer literal (x += n) */
  stmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Case 2: Binary expression assignment with same variable (x = x + n) */
  exists(Name targetVar, BinaryExpr binExpr |
    targetVar = stmt.(AssignStmt).getTarget(0) and
    binExpr = stmt.(AssignStmt).getValue() and
    binExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    binExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Checks if a for loop implements counting behavior where iteration variable increments
 * @param loop The for loop to examine
 */
predicate is_counting_loop(For loop) { 
  is_increment_operation(loop.getAStmt()) 
}

/**
 * Determines if a for loop body is empty (contains only Pass statement)
 * @param loop The for loop to examine
 */
predicate is_empty_loop(For loop) { 
  not exists(loop.getStmt(1)) and 
  loop.getStmt(0) instanceof Pass 
}

/**
 * Checks if a for loop contains only a single exit statement (return/break)
 * @param loop The for loop to examine
 */
predicate has_single_exit_statement(For loop) {
  not exists(Continue continueStmt | loop.contains(continueStmt)) and
  exists(Stmt terminalStmt | terminalStmt = loop.getBody().getLastItem() |
    terminalStmt instanceof Return or terminalStmt instanceof Break
  )
}

/**
 * Identifies calls to range/xrange functions including nested patterns
 * @param node The control flow node to analyze
 */
predicate is_range_function_call(ControlFlowNode node) {
  /* Direct range/xrange function calls */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or rangeFunc = Value::named("xrange")
  |
    node = rangeFunc.getACall()
  )
  or
  /* Name-based range/xrange calls */
  exists(string funcName | node.getNode().(Call).getFunc().(Name).getId() = funcName |
    funcName = "range" or funcName = "xrange"
  )
  or
  /* Nested calls like list(range(...)) */
  node.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(node.(CallNode).getArg(0))
}

/**
 * Detects names that use non-constant variables with dynamic definitions
 * @param nameNode The name node to analyze
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable var |
    nameNode.uses(var) and
    /* Exclude module-level references */
    not nameNode.getScope() instanceof Module and
    not var.getScope() instanceof Module
  |
    /* Variable has multiple definitions */
    strictcount(Name def | def.defines(var)) > 1
    or
    /* Variable defined inside a for loop */
    exists(For loop, Name def | loop.contains(def) and def.defines(var))
    or
    /* Variable defined inside a while loop */
    exists(While loop, Name def | loop.contains(def) and def.defines(var))
  )
}

/**
 * Identifies loops that perform implicit N-time operations with immutable literals
 * @param loop The for loop to examine
 */
predicate is_implicit_repetition(For loop) {
  /* Loop body contains exactly one statement */
  not exists(loop.getStmt(1)) and
  /* Statement contains an immutable literal */
  exists(ImmutableLiteral lit | loop.getStmt(0).contains(lit)) and
  /* No non-constant variable usage in body */
  not exists(Name varName | loop.getBody().contains(varName) and uses_non_constant_variable(varName))
}

/**
 * Retrieves the iterable from a comprehension's for statement
 * @param compFor The artificial for statement in comprehension
 * @return Control flow node of the iterable
 */
ControlFlowNode get_comprehension_iterable(For compFor) {
  exists(Comp compExpr | 
    compExpr.getFunction().getStmt(0) = compFor | 
    compExpr.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if variable name follows convention for unused variables (starts with underscore)
 * @param var The variable to examine
 */
predicate name_acceptable_for_unused_variable(Variable var) {
  exists(string varName | varName = var.getId() and varName.matches("_%"))
}

/**
 * Main query logic to detect unused loop iteration variables
 */
from For loop, Variable iterVar, string warningMsg
where
  /* Basic condition: iteration variable is defined but never used */
  loop.getTarget() = iterVar.getAnAccess() and
  not loop.getAStmt().contains(iterVar.getAnAccess()) and
  
  /* Exclude common false-positive patterns */
  not is_range_function_call(loop.getIter().getAFlowNode()) and
  not is_range_function_call(get_comprehension_iterable(loop)) and
  not name_acceptable_for_unused_variable(iterVar) and
  not loop.getScope().getName() = "genexpr" and
  not is_empty_loop(loop) and
  not has_single_exit_statement(loop) and
  not is_counting_loop(loop) and
  not is_implicit_repetition(loop) and
  
  /* Generate context-specific warning message */
  (if exists(Name delNode | delNode.deletes(iterVar) and loop.getAStmt().contains(delNode))
   then warningMsg = "' is deleted but never used in the loop body."
   else warningMsg = "' is never used in the loop body.")
select loop, "For loop variable '" + iterVar.getId() + warningMsg