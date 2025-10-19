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
predicate isMainGuardCheck(If guardIfStmt) {
  exists(Name nameNode, StringLiteral mainLiteral, Compare comparisonExpr |
    guardIfStmt.getTest() = comparisonExpr and
    comparisonExpr.getLeft() = nameNode and
    comparisonExpr.getAComparator() = mainLiteral and
    nameNode.getId() = "__name__" and
    mainLiteral.getText() = "__main__"
  )
}

// Identifies both Python 2 print statements and Python 3 print function calls
predicate isUnwantedPrint(Stmt stmt) {
  stmt instanceof Print
  or
  exists(ExprStmt exprStmt, Call printCall, Name printFuncName |
    exprStmt = stmt and
    printCall = exprStmt.getValue() and
    printFuncName = printCall.getFunc() and
    printFuncName.getId() = "print"
  )
}

// Find print statements that execute during module import
from Stmt problematicPrint
where
  isUnwantedPrint(problematicPrint) and
  // Verify the statement is in a module scope used for imports
  exists(ModuleValue importedModule | 
    importedModule.getScope() = problematicPrint.getScope() and 
    importedModule.isUsedAsModule()
  ) and
  // Ensure the print is not protected by a main guard
  not exists(If guardIfStmt | 
    isMainGuardCheck(guardIfStmt) and 
    guardIfStmt.getASubStatement().getASubStatement*() = problematicPrint
  )
select problematicPrint, "Print statement may execute during import."