/**
 * @name Unreachable code
 * @description Identifies code that can never be executed
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-561
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-statement
 */

import python

// Determines if an import statement is used solely for type hints
predicate is_typing_import(ImportingStmt importDecl) {
  exists(Module mod |
    importDecl.getScope() = mod and // Check if import is at module level
    exists(TypeHintComment typeHint | typeHint.getLocation().getFile() = mod.getFile()) // Verify type hints exist in module
  )
}

// Checks if a statement contains the only yield expression in its function scope
predicate has_unique_yield(Stmt targetStmt) {
  exists(Yield yieldExpr | targetStmt.contains(yieldExpr)) and // Statement contains a yield
  exists(Function enclosingFunc |
    enclosingFunc = targetStmt.getScope() and // Get containing function
    strictcount(Yield y | enclosingFunc.containsInScope(y)) = 1 // Function has exactly one yield
  )
}

// Detects if contextlib.suppress is used in the same scope as the statement
predicate has_suppression_in_scope(Stmt targetStmt) {
  exists(With withBlock |
    withBlock.getContextExpr().(Call).getFunc().pointsTo(Value::named("contextlib.suppress")) and // Context manager is suppress
    withBlock.getScope() = targetStmt.getScope() // Same scope as target statement
  )
}

// Identifies statements that mark impossible else branches (always-raising)
predicate is_impossible_else_branch(Stmt targetStmt) {
  exists(If ifBlock | ifBlock.getOrelse().getItem(0) = targetStmt |
    targetStmt.(Assert).getTest() instanceof False // Always-false assertion
    or
    targetStmt instanceof Raise // Always-raising exception
  )
}

// Determines if a statement qualifies as reportable unreachable code
predicate is_reportable_unreachable(Stmt targetStmt) {
  targetStmt.isUnreachable() and // Statement is fundamentally unreachable
  not is_typing_import(targetStmt) and // Exclude type-hint imports
  not has_suppression_in_scope(targetStmt) and // Exclude suppressed contexts
  not exists(Stmt otherUnreachable | otherUnreachable.isUnreachable() |
    otherUnreachable.contains(targetStmt) // Exclude nested unreachable statements
    or
    exists(StmtList containerList, int earlierIdx, int laterIdx | 
      containerList.getItem(earlierIdx) = otherUnreachable and 
      containerList.getItem(laterIdx) = targetStmt and 
      earlierIdx < laterIdx // Exclude statements following other unreachable code
    )
  ) and
  not has_unique_yield(targetStmt) and // Exclude generator functions with single yield
  not is_impossible_else_branch(targetStmt) // Exclude intentional impossible branches
}

// Main query: Find and report unreachable code
from Stmt targetStmt
where is_reportable_unreachable(targetStmt)
select targetStmt, "This statement is unreachable."