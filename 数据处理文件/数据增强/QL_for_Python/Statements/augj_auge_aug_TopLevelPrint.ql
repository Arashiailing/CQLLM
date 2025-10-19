/**
 * @name Print statement execution during module import
 * @description Identifies print statements at module scope not protected by `if __name__ == '__main__'`.
 *              Such statements trigger output during module import, which is typically unintended.
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

// Identifies conditional blocks checking if __name__ equals "__main__"
predicate isMainGuard(If ifStmt) {
  exists(Name nameVar, StringLiteral mainStr, Compare comparison |
    ifStmt.getTest() = comparison and          // Get condition from if statement
    comparison.getLeft() = nameVar and          // Left operand is __name__
    comparison.getAComparator() = mainStr and   // Right operand is "__main__"
    nameVar.getId() = "__name__" and            // Verify left operand
    mainStr.getText() = "__main__"              // Verify right operand
  )
}

// Detects both Python 2 print statements and Python 3 print function calls
predicate isPrintUsage(Stmt stmt) {
  stmt instanceof Print                          // Python 2 print statement
  or
  exists(ExprStmt exprStmt, Call callExpr, Name funcName |
    exprStmt = stmt and                          // Statement is expression
    callExpr = exprStmt.getValue() and           // Get call expression
    funcName = callExpr.getFunc() and            // Get function name
    funcName.getId() = "print"                   // Verify print function
  )
}

// Locate print statements executing during module import
from Stmt printStmt
where
  // Confirm statement is a print operation
  isPrintUsage(printStmt)
  and
  // Verify statement resides in a module used for import
  // TODO: Future enhancement needed for ModuleObject.getKind handling
  exists(ModuleValue moduleVal | 
    moduleVal.getScope() = printStmt.getScope() and 
    moduleVal.isUsedAsModule()
  )
  and
  // Ensure print statement isn't inside __main__ guard block
  not exists(If ifStmt | 
    isMainGuard(ifStmt) and 
    ifStmt.getASubStatement().getASubStatement*() = printStmt
  )
select printStmt, "Print statement may execute during import."