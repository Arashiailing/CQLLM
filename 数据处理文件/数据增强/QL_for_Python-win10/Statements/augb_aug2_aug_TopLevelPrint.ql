/**
 * @name Print statement execution during module import
 * @description Identifies unguarded print statements at module scope that execute during import,
 *              which can cause unintended output when the module is loaded.
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

// Detects if statements that guard code with `if __name__ == '__main__'`
predicate isMainGuard(If ifStmt) {
  exists(Name nameExpr, StringLiteral mainStr, Compare compareExpr |
    ifStmt.getTest() = compareExpr and          // Condition of the if statement
    compareExpr.getLeft() = nameExpr and        // Left operand is __name__
    compareExpr.getAComparator() = mainStr and  // Right operand is "__main__"
    nameExpr.getId() = "__name__" and           // Verify left operand
    mainStr.getText() = "__main__"             // Verify right operand
  )
}

// Identifies both Python 2 print statements and Python 3 print function calls
predicate isPrintOperation(Stmt stmt) {
  stmt instanceof Print  // Python 2 print statement
  or
  exists(ExprStmt exprStmt, Call call, Name funcName |
    exprStmt = stmt and                  // Statement is an expression
    call = exprStmt.getValue() and       // Get the call expression
    funcName = call.getFunc() and        // Get the function name
    funcName.getId() = "print"           // Verify it's the print function
  )
}

// Find print statements that execute during module import
from Stmt printStmt
where
  isPrintOperation(printStmt) and             // Confirm it's a print operation
  // Check if the statement is in a module used for importing
  exists(ModuleValue moduleVal | 
    moduleVal.getScope() = printStmt.getScope() and 
    moduleVal.isUsedAsModule()                // Module is imported elsewhere
  ) and
  // Ensure the print isn't inside a main guard block
  not exists(If ifGuard | 
    isMainGuard(ifGuard) and 
    ifGuard.getASubStatement().getASubStatement*() = printStmt
  )
select printStmt, "Print statement may execute during import."