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
 * @param loopStmt Loop to analyze for counting patterns.
 */
predicate is_counting_loop(For loopStmt) { 
  is_increment_operation(loopStmt.getAStmt()) 
}

/**
 * Determines if a for loop contains only a Pass statement.
 * @param loopStmt Loop to check for emptiness.
 */
predicate is_empty_loop(For loopStmt) { 
  not exists(loopStmt.getStmt(1)) and 
  loopStmt.getStmt(0) instanceof Pass 
}

/**
 * Checks if a for loop contains only a single exit statement (return/break).
 * @param loopStmt Loop to analyze for exit patterns.
 */
predicate has_single_exit_statement(For loopStmt) {
  not exists(Continue c | loopStmt.contains(c)) and
  exists(Stmt finalStmt | finalStmt = loopStmt.getBody().getLastItem() |
    finalStmt instanceof Return
    or
    finalStmt instanceof Break
  )
}

/**
 * Identifies calls to range/xrange functions or classes.
 * @param flowNode Control flow node to analyze.
 */
predicate is_range_function_call(ControlFlowNode flowNode) {
  /* Handle direct range/xrange calls */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or
    rangeFunc = Value::named("xrange")
  |
    flowNode = rangeFunc.getACall()
  )
  or
  /* Handle imported range calls (e.g., from six.moves import range) */
  exists(string rangeFuncName | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = rangeFuncName |
    rangeFuncName = "range" or rangeFuncName = "xrange"
  )
  or
  /* Handle nested calls (e.g., list(range(...))) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_function_call(flowNode.(CallNode).getArg(0))
}

/**
 * Checks if a name node uses non-constant variables.
 * @param nameNode Name node to analyze.
 */
predicate uses_non_constant_variable(Name nameNode) {
  exists(Variable var |
    nameNode.uses(var) and
    /* Exclude module-level usage */
    not nameNode.getScope() instanceof Module and
    /* Exclude global variables */
    not var.getScope() instanceof Module
  |
    /* Variable has multiple definitions (dynamic) */
    strictcount(Name def | def.defines(var)) > 1
    or
    /* Variable defined in a for loop */
    exists(For loop, Name def | loop.contains(def) and def.defines(var))
    or
    /* Variable defined in a while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(var))
  )
}

/**
 * Identifies loops that implicitly repeat operations N times.
 * @param loopStmt Loop to analyze for repetition patterns.
 */
predicate is_implicit_repetition(For loopStmt) {
  /* Loop body contains exactly one statement */
  not exists(loopStmt.getStmt(1)) and
  /* Statement contains an immutable literal */
  exists(ImmutableLiteral immutable | 
    loopStmt.getStmt(0).contains(immutable)) and
  /* No non-constant variable usage */
  not exists(Name nameNode | 
    loopStmt.getBody().contains(nameNode) and uses_non_constant_variable(nameNode))
}

/**
 * Retrieves the iterable object from a comprehension's for statement.
 * @param compLoop Artificial for statement in a comprehension.
 * @return Control flow node of the iterable object.
 */
ControlFlowNode get_comprehension_iterable(For compLoop) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = compLoop | 
    comprehension.getAFlowNode().getAPredecessor() = result
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
from For loopStmt, Variable iterVar, string alertMsg
where
  /* Basic condition: loop target is the iteration variable */
  loopStmt.getTarget() = iterVar.getAnAccess() and
  /* Variable not used in loop body */
  not loopStmt.getAStmt().contains(iterVar.getAnAccess()) and
  
  /* Filter out false positives */
  /* Iterator not a range/xrange call */
  not is_range_function_call(loopStmt.getIter().getAFlowNode()) and
  /* Comprehension iterator not a range/xrange call */
  not is_range_function_call(get_comprehension_iterable(loopStmt)) and
  /* Variable name not acceptable for unused */
  not name_acceptable_for_unused_variable(iterVar) and
  
  /* Exclude specific loop patterns */
  /* Exclude generator expressions */
  not loopStmt.getScope().getName() = "genexpr" and
  /* Exclude empty loops */
  not is_empty_loop(loopStmt) and
  /* Exclude single-exit loops */
  not has_single_exit_statement(loopStmt) and
  /* Exclude counting loops */
  not is_counting_loop(loopStmt) and
  /* Exclude implicit repetition loops */
  not is_implicit_repetition(loopStmt) and
  
  /* Generate appropriate warning message */
  if exists(Name delNode | delNode.deletes(iterVar) and loopStmt.getAStmt().contains(delNode))
  then alertMsg = "' is deleted, but not used, in the loop body."
  else alertMsg = "' is not used in the loop body."
select loopStmt, "For loop variable '" + iterVar.getId() + alertMsg