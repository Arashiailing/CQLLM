/**
 * @name Use of a print statement at module level
 * @description Detects print statements at module scope that execute during import, 
 *              except when guarded by `if __name__ == '__main__'`. Such statements 
 *              cause unexpected output when the module is imported.
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
 * Identifies `if __name__ == '__main__'` guard blocks.
 * @param ifStmt - The If statement node to check
 */
predicate isMainGuard(If ifStmt) {
  exists(Name nameNode, StringLiteral mainLiteral, Compare compareExpr |
    ifStmt.getTest() = compareExpr and          // Get the condition expression
    compareExpr.getLeft() = nameNode and        // Left operand must be __name__
    compareExpr.getAComparator() = mainLiteral and // Right operand must be "__main__"
    nameNode.getId() = "__name__" and           // Verify left operand is __name__
    mainLiteral.getText() = "__main__"          // Verify right operand is "__main__"
  )
}

/**
 * Identifies print statements (both Python 2 print statements and Python 3 print function calls).
 * @param stmt - The statement node to check
 */
predicate isPrintStatement(Stmt stmt) {
  stmt instanceof Print                          // Python 2 print statement
  or
  exists(ExprStmt exprStmt, Call callExpr, Name funcName |
    exprStmt = stmt and                         // Must be an expression statement
    callExpr = exprStmt.getValue() and          // Get the call expression
    funcName = callExpr.getFunc() and           // Get the function name
    funcName.getId() = "print"                  // Verify function is print()
  )
}

// Main query to detect problematic print statements
from Stmt printStmt
where
  isPrintStatement(printStmt) and               // Statement must be a print
  // TODO: Need to discuss how we would like to handle ModuleObject.getKind in the glorious future
  exists(ModuleValue moduleVal |                // Verify module context
    moduleVal.getScope() = printStmt.getScope() and // Statement must be in module scope
    moduleVal.isUsedAsModule()                  // Module must be importable
  ) and
  not exists(If guardBlock |                    // Ensure not inside main guard
    isMainGuard(guardBlock) and
    guardBlock.getASubStatement().getASubStatement*() = printStmt
  )
select printStmt, "Print statement may execute during import."