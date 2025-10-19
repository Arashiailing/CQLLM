/**
 * @name Dead code detection
 * @description Identifies code that cannot be executed
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

// Determines if an import statement is used for type hints
// Such imports should not be flagged as unreachable code
predicate is_typing_related_import(ImportingStmt typingImport) {
  exists(Module modScope |
    typingImport.getScope() = modScope and
    exists(TypeHintComment typeHintComment | typeHintComment.getLocation().getFile() = modScope.getFile())
  )
}

// Checks if a statement contains the only yield expression in its function
// Such code blocks may be intentionally designed as generator functions
predicate contains_unique_yield_in_function(Stmt stmtContainingYield) {
  exists(Yield yieldNode | stmtContainingYield.contains(yieldNode)) and
  exists(Function funcScope |
    funcScope = stmtContainingYield.getScope() and
    strictcount(Yield yieldNode | funcScope.containsInScope(yieldNode)) = 1
  )
}

// Verifies if a statement shares scope with contextlib.suppress
// Code blocks using contextlib.suppress may intentionally catch exceptions
predicate shares_scope_with_suppression(Stmt stmtInSuppressScope) {
  exists(With suppressWithStmt |
    suppressWithStmt.getContextExpr().(Call).getFunc().pointsTo(Value::named("contextlib.suppress")) and
    suppressWithStmt.getScope() = stmtInSuppressScope.getScope()
  )
}

// Identifies statements marking impossible else branches
// Defensive programming patterns may use unreachable else branches with assertions/exceptions
predicate marks_impossible_else_branch(Stmt stmtInImpossibleElse) {
  exists(If ifBlock | ifBlock.getOrelse().getItem(0) = stmtInImpossibleElse |
    stmtInImpossibleElse.(Assert).getTest() instanceof False
    or
    stmtInImpossibleElse instanceof Raise
  )
}

// Determines if a statement should be reported as unreachable
// Combines multiple conditions to exclude legitimate unreachable code cases
predicate is_reportable_unreachable(Stmt deadCode) {
  // Base condition: statement must be unreachable
  deadCode.isUnreachable() and
  
  // Exclude legitimate cases of unreachable code
  not is_typing_related_import(deadCode) and
  not shares_scope_with_suppression(deadCode) and
  not contains_unique_yield_in_function(deadCode) and
  not marks_impossible_else_branch(deadCode) and
  
  // Exclude statements contained within or following other unreachable statements
  not exists(Stmt otherUnreachable | otherUnreachable.isUnreachable() |
    otherUnreachable.contains(deadCode)
    or
    exists(StmtList statementList, int previousIndex, int currentIndex | 
      statementList.getItem(previousIndex) = otherUnreachable and 
      statementList.getItem(currentIndex) = deadCode and 
      previousIndex < currentIndex
    )
  )
}

// Query for all reportable unreachable code
from Stmt deadCode
where is_reportable_unreachable(deadCode)
select deadCode, "This statement is unreachable."