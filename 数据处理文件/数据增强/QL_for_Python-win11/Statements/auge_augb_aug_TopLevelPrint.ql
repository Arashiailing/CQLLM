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

// Identifies if statements that check if __name__ == '__main__'
predicate isMainGuardCheck(If mainGuard) {
  exists(Name nameVar, StringLiteral mainStr, Compare comparison |
    mainGuard.getTest() = comparison and
    comparison.getLeft() = nameVar and
    comparison.getAComparator() = mainStr and
    nameVar.getId() = "__name__" and
    mainStr.getText() = "__main__"
  )
}

// Identifies both Python 2 print statements and Python 3 print function calls
predicate isUnwantedPrint(Stmt printStmt) {
  printStmt instanceof Print
  or
  exists(ExprStmt exprStmt, Call callNode, Name funcName |
    exprStmt = printStmt and
    callNode = exprStmt.getValue() and
    funcName = callNode.getFunc() and
    funcName.getId() = "print"
  )
}

// Find print statements that execute during module import
from Stmt unwantedPrint
where
  isUnwantedPrint(unwantedPrint) and
  // Verify the statement is in a module scope used for imports
  exists(ModuleValue moduleVal | 
    moduleVal.getScope() = unwantedPrint.getScope() and 
    moduleVal.isUsedAsModule()
  ) and
  // Ensure the print is not protected by a main guard
  not exists(If mainGuard | 
    isMainGuardCheck(mainGuard) and 
    mainGuard.getASubStatement().getASubStatement*() = unwantedPrint
  )
select unwantedPrint, "Print statement may execute during import."