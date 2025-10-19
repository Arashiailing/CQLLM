/**
 * @name Use of a print statement at module level
 * @description Detects print statements at module scope that are not guarded by `if __name__ == '__main__'`.
 *              Such statements can cause unexpected output when the module is imported.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/print-during-import
 */

import python

/**
 * Identifies if statements with the condition `__name__ == "__main__"`.
 * This pattern guards code that should only execute when the module is run directly,
 * preventing execution during import operations.
 */
predicate isMainGuardCondition(If guardIf) {
  exists(Name nameNode, StringLiteral mainLiteral, Compare compareNode |
    guardIf.getTest() = compareNode and
    compareNode.getLeft() = nameNode and
    compareNode.getAComparator() = mainLiteral and
    nameNode.getId() = "__name__" and
    mainLiteral.getText() = "__main__"
  )
}

/**
 * Determines if a statement is a print operation.
 * Covers both Python 2 print statements and Python 3 print() function calls.
 */
predicate isPrintStatement(Stmt stmt) {
  stmt instanceof Print
  or
  exists(ExprStmt exprStmt, Call callExpr, Name funcName |
    exprStmt = stmt and
    callExpr = exprStmt.getValue() and
    funcName = callExpr.getFunc() and
    funcName.getId() = "print"
  )
}

/**
 * Locates unguarded print statements at module level.
 * These statements execute during module import, potentially causing unintended side effects.
 */
from Stmt unguardedPrint
where
  // Verify the statement is a print operation
  isPrintStatement(unguardedPrint) and
  // Ensure the statement exists in an importable module
  exists(ModuleValue moduleNode | 
    moduleNode.getScope() = unguardedPrint.getScope() and 
    moduleNode.isUsedAsModule()
  ) and
  // Confirm the print is not protected by a main guard
  not exists(If guardIf | 
    isMainGuardCondition(guardIf) and 
    guardIf.getASubStatement().getASubStatement*() = unguardedPrint
  )
select unguardedPrint, "Print statement may execute during import."