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

// Identifies if statements checking for __name__ == '__main__'
predicate isMainGuard(If ifStmt) {
  exists(Name nameNode, StringLiteral mainLiteral, Compare comparison |
    ifStmt.getTest() = comparison and
    comparison.getLeft() = nameNode and
    comparison.getAComparator() = mainLiteral and
    nameNode.getId() = "__name__" and
    mainLiteral.getText() = "__main__"
  )
}

// Identifies both Python 2 print statements and Python 3 print function calls
predicate isPrintCall(Stmt stmt) {
  stmt instanceof Print
  or
  exists(ExprStmt exprStmt, Call callNode, Name nameNode |
    exprStmt = stmt and
    callNode = exprStmt.getValue() and
    nameNode = callNode.getFunc() and
    nameNode.getId() = "print"
  )
}

// Find problematic print statements in module scope
from Stmt problematicPrintStmt
where
  isPrintCall(problematicPrintStmt) and
  // TODO: Future enhancement: Consider ModuleObject.getKind handling
  exists(ModuleValue moduleVal | 
    moduleVal.getScope() = problematicPrintStmt.getScope() and 
    moduleVal.isUsedAsModule()
  ) and
  not exists(If ifStmt | 
    isMainGuard(ifStmt) and 
    ifStmt.getASubStatement().getASubStatement*() = problematicPrintStmt
  )
select problematicPrintStmt, "Print statement may execute during import."