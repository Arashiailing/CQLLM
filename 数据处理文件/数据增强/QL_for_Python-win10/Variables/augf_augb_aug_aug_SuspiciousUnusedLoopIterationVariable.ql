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
 * Detects statements that perform increment operations (e.g., x += n or x = x + n).
 * @param stmt The statement to be analyzed.
 */
predicate is_increment_operation(Stmt stmt) {
  /* Handles augmented assignment with integer literal */
  stmt.(AugAssign).getValue() instanceof IntegerLiteral
  or
  /* Handles standard assignment with addition pattern */
  exists(Name targetVar, BinaryExpr addExpr |
    targetVar = stmt.(AssignStmt).getTarget(0) and
    addExpr = stmt.(AssignStmt).getValue() and
    addExpr.getLeft().(Name).getVariable() = targetVar.getVariable() and
    addExpr.getRight() instanceof IntegerLiteral
  )
}

/**
 * Identifies loops where the iteration variable is used for counting.
 * @param forLoop The for loop to be examined.
 */
predicate is_counting_pattern(For forLoop) { 
  is_increment_operation(forLoop.getAStmt()) 
}

/**
 * Detects loops that contain only a Pass statement.
 * @param forLoop The for loop to be examined.
 */
predicate is_pass_only_loop(For forLoop) { 
  not exists(forLoop.getStmt(1)) and 
  forLoop.getStmt(0) instanceof Pass 
}

/**
 * Identifies loops with a single exit point (return/break) and no continue statements.
 * @param forLoop The for loop to be examined.
 */
predicate has_single_exit(For forLoop) {
  not exists(Continue c | forLoop.contains(c)) and
  exists(Stmt lastStmt | lastStmt = forLoop.getBody().getLastItem() |
    lastStmt instanceof Return or lastStmt instanceof Break
  )
}

/**
 * Detects calls to range/xrange functions or classes.
 * @param flowNode The control flow node to be analyzed.
 */
predicate is_range_call(ControlFlowNode flowNode) {
  /* Direct range/xrange references */
  exists(Value rangeFunc |
    rangeFunc = Value::named("range") or rangeFunc = Value::named("xrange")
  |
    flowNode = rangeFunc.getACall()
  )
  or
  /* Named range/xrange calls */
  exists(string rangeName | 
    flowNode.getNode().(Call).getFunc().(Name).getId() = rangeName |
    rangeName = "range" or rangeName = "xrange"
  )
  or
  /* Nested calls like list(range(...)) */
  flowNode.(CallNode).pointsTo().getClass() = ClassValue::list() and
  is_range_call(flowNode.(CallNode).getArg(0))
}

/**
 * Identifies name expressions that reference non-constant variables.
 * @param nameExpr The name expression to be analyzed.
 */
predicate references_non_constant(Name nameExpr) {
  exists(Variable variable |
    nameExpr.uses(variable) and
    /* Local scope usage */
    not nameExpr.getScope() instanceof Module and
    /* Non-global variable */
    not variable.getScope() instanceof Module
  |
    /* Dynamically defined variable */
    strictcount(Name def | def.defines(variable)) > 1
    or
    /* Variable defined in for loop */
    exists(For forLoop, Name def | forLoop.contains(def) and def.defines(variable))
    or
    /* Variable defined in while loop */
    exists(While whileLoop, Name def | whileLoop.contains(def) and def.defines(variable))
  )
}

/**
 * Identifies loops that perform the same operation multiple times without using the iteration variable.
 * @param forLoop The for loop to be examined.
 */
predicate is_fixed_repetition(For forLoop) {
  /* Single statement loop body */
  not exists(forLoop.getStmt(1)) and
  /* Contains immutable literal */
  exists(ImmutableLiteral literal | forLoop.getStmt(0).contains(literal)) and
  /* No non-constant variable usage */
  not exists(Name nameExpr | 
    forLoop.getBody().contains(nameExpr) and references_non_constant(nameExpr))
}

/**
 * Retrieves the iterable object from a comprehension's artificial for statement.
 * @param compFor The artificial for statement in comprehension.
 * @return The iterable's control flow node.
 */
ControlFlowNode get_comprehension_source(For compFor) {
  exists(Comp comprehension | 
    comprehension.getFunction().getStmt(0) = compFor | 
    comprehension.getAFlowNode().getAPredecessor() = result
  )
}

/**
 * Checks if a variable name indicates it's intentionally unused (starts with underscore).
 * @param variable The variable to be checked.
 */
predicate is_intentionally_unused(Variable variable) {
  exists(string name | name = variable.getId() and name.matches("_%"))
}

/**
 * Detects unused loop iteration variables with appropriate warning messages.
 */
from For loop, Variable iterationVar, string message
where
  /* Identify the iteration variable */
  loop.getTarget() = iterationVar.getAnAccess() and
  /* Check if variable is unused in loop body */
  not loop.getAStmt().contains(iterationVar.getAnAccess()) and
  /* Exclude range-based iterators */
  not is_range_call(loop.getIter().getAFlowNode()) and
  /* Exclude range-based comprehension iterators */
  not is_range_call(get_comprehension_source(loop)) and
  /* Exclude intentionally unused variables */
  not is_intentionally_unused(iterationVar) and
  /* Exclude generator expressions */
  not loop.getScope().getName() = "genexpr" and
  /* Exclude specific loop patterns */
  not is_pass_only_loop(loop) and
  not has_single_exit(loop) and
  not is_counting_pattern(loop) and
  not is_fixed_repetition(loop) and
  /* Generate appropriate warning message */
  if exists(Name delNode | delNode.deletes(iterationVar) and loop.getAStmt().contains(delNode))
  then message = "' is deleted, but not used, in the loop body."
  else message = "' is not used in the loop body."
select loop, "For loop variable '" + iterationVar.getId() + message