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
predicate isMainGuardCondition(If ifNode) {
  exists(Name nameNode, StringLiteral mainLiteral, Compare compareNode |
    ifNode.getTest() = compareNode and
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
  exists(ExprStmt exprNode, Call callNode, Name funcNode |
    exprNode = stmt and
    callNode = exprNode.getValue() and
    funcNode = callNode.getFunc() and
    funcNode.getId() = "print"
  )
}

/**
 * Locates unguarded print statements at module level.
 * These statements execute during module import, potentially causing unintended side effects.
 */
from Stmt printNode
where
  isPrintStatement(printNode) and
  // Verify the statement exists in an importable module
  exists(ModuleValue moduleNode | 
    moduleNode.getScope() = printNode.getScope() and 
    moduleNode.isUsedAsModule()
  ) and
  // Ensure the print is not protected by a main guard
  not exists(If ifNode | 
    isMainGuardCondition(ifNode) and 
    ifNode.getASubStatement().getASubStatement*() = printNode
  )
select printNode, "Print statement may execute during import."