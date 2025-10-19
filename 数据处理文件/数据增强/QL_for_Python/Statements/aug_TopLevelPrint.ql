/**
 * @name Use of a print statement at module level
 * @description Detects print statements at module scope that are not guarded by `if __name__ == '__main__'`.
 *              Such statements will produce output when the module is imported, which is often unintended.
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

// Predicate to identify if statements that check if __name__ == '__main__'
predicate isMainNameCheck(If ifStmt) {
  exists(Name nameVar, StringLiteral mainStr, Compare compareExpr |
    ifStmt.getTest() = compareExpr and // Get the condition of the if statement
    compareExpr.getLeft() = nameVar and // Left operand is __name__
    compareExpr.getAComparator() = mainStr and // Right operand is "__main__"
    nameVar.getId() = "__name__" and // Confirm left operand is __name__
    mainStr.getText() = "__main__" // Confirm right operand is "__main__"
  )
}

// Predicate to identify print statements (both Python 2 print statements and Python 3 print function calls)
predicate isPrintStatement(Stmt stmt) {
  stmt instanceof Print // Python 2 print statement
  or
  exists(ExprStmt exprStmt, Call funcCall, Name funcName |
    exprStmt = stmt and // Statement is an expression statement
    funcCall = exprStmt.getValue() and // Get the call part of the expression
    funcName = funcCall.getFunc() and // Get the function name being called
    funcName.getId() = "print" // Confirm function name is print
  )
}

// From all statements, find print statements that meet our criteria
from Stmt printStmt
where
  isPrintStatement(printStmt) and // Confirm the statement is a print statement
  // TODO: Need to discuss how we would like to handle ModuleObject.getKind in the glorious future
  exists(ModuleValue moduleVal | moduleVal.getScope() = printStmt.getScope() and moduleVal.isUsedAsModule()) and // Check if the statement is in a module that is used as an imported module
  not exists(If ifStmt | isMainNameCheck(ifStmt) and ifStmt.getASubStatement().getASubStatement*() = printStmt) // Ensure the print statement is not inside an if __name__ == '__main__' block
select printStmt, "Print statement may execute during import."