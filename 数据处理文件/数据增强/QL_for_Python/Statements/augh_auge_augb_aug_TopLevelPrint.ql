/**
 * @name Print statement at module level without main guard
 * @description Identifies print statements in module scope that aren't protected by 
 *              `if __name__ == '__main__'` guards. These statements execute during 
 *              module import, which is typically unintended behavior.
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

// Checks if an If statement implements the standard Python main guard pattern
predicate isMainGuard(If guardStmt) {
  exists(Name nameVar, StringLiteral mainLiteral, Compare comparison |
    guardStmt.getTest() = comparison and
    comparison.getLeft() = nameVar and
    comparison.getAComparator() = mainLiteral and
    nameVar.getId() = "__name__" and
    mainLiteral.getText() = "__main__"
  )
}

// Detects both Python 2 print statements and Python 3 print function calls
predicate isPrintStatement(Stmt stmt) {
  stmt instanceof Print
  or
  exists(ExprStmt exprStmt, Call callNode, Name funcName |
    exprStmt = stmt and
    callNode = exprStmt.getValue() and
    funcName = callNode.getFunc() and
    funcName.getId() = "print"
  )
}

// Find print statements that execute during module import
from Stmt printStmt
where
  isPrintStatement(printStmt) and
  // Verify the statement is in a module scope used for imports
  exists(ModuleValue moduleVal | 
    moduleVal.getScope() = printStmt.getScope() and 
    moduleVal.isUsedAsModule()
  ) and
  // Ensure the print is not protected by a main guard
  not exists(If guardStmt | 
    isMainGuard(guardStmt) and 
    guardStmt.getASubStatement().getASubStatement*() = printStmt
  )
select printStmt, "Print statement may execute during import."