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
 * Checks if an if statement has the condition `__name__ == "__main__"`.
 * This is typically used to guard code that should only run when the module is executed directly,
 * not when it is imported.
 */
predicate isMainGuardCondition(If ifStmt) {
  exists(Name nameVar, StringLiteral mainStr, Compare compareExpr |
    ifStmt.getTest() = compareExpr and
    compareExpr.getLeft() = nameVar and
    compareExpr.getAComparator() = mainStr and
    nameVar.getId() = "__name__" and
    mainStr.getText() = "__main__"
  )
}

/**
 * Determines if a statement is a print statement.
 * This includes both the legacy Python 2 print statement and the Python 3 print() function call.
 */
predicate isPrintStatement(Stmt statement) {
  statement instanceof Print
  or
  exists(ExprStmt exprStmt, Call callExpr, Name funcName |
    exprStmt = statement and
    callExpr = exprStmt.getValue() and
    funcName = callExpr.getFunc() and
    funcName.getId() = "print"
  )
}

/**
 * Finds print statements at module level that are not guarded by `if __name__ == '__main__'`.
 * Such print statements will execute when the module is imported, which is usually unintended behavior.
 */
from Stmt printStmt
where
  isPrintStatement(printStmt) and
  // Check if the statement is in a module that can be imported
  exists(ModuleValue moduleVal | moduleVal.getScope() = printStmt.getScope() and moduleVal.isUsedAsModule()) and
  // Ensure the print statement is not inside a `if __name__ == '__main__'` block
  not exists(If ifStmt | 
    isMainGuardCondition(ifStmt) and 
    ifStmt.getASubStatement().getASubStatement*() = printStmt
  )
select printStmt, "Print statement may execute during import."