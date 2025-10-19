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

// Predicate to identify if statements checking if __name__ == '__main__'
predicate isMainNameCheck(If ifNode) {
  exists(Name nameNode, StringLiteral mainLiteral, Compare comparisonNode |
    ifNode.getTest() = comparisonNode and // Get the condition of the if statement
    comparisonNode.getLeft() = nameNode and // Left operand is __name__
    comparisonNode.getAComparator() = mainLiteral and // Right operand is "__main__"
    nameNode.getId() = "__name__" and // Confirm left operand is __name__
    mainLiteral.getText() = "__main__" // Confirm right operand is "__main__"
  )
}

// Predicate to identify print statements (both Python 2 print statements and Python 3 print function calls)
predicate isPrintStatement(Stmt statement) {
  statement instanceof Print // Python 2 print statement
  or
  exists(ExprStmt exprStatement, Call callNode, Name funcNameNode |
    exprStatement = statement and // Statement is an expression statement
    callNode = exprStatement.getValue() and // Get the call part of the expression
    funcNameNode = callNode.getFunc() and // Get the function name being called
    funcNameNode.getId() = "print" // Confirm function name is print
  )
}

// Find print statements that execute during import
from Stmt printStatement
where
  // Verify it's a print statement
  isPrintStatement(printStatement)
  and
  // Check if the statement is in a module used as an imported module
  // TODO: Need to discuss how we would like to handle ModuleObject.getKind in the glorious future
  exists(ModuleValue moduleValue | 
    moduleValue.getScope() = printStatement.getScope() and 
    moduleValue.isUsedAsModule()
  )
  and
  // Ensure the print statement is not inside an if __name__ == '__main__' block
  not exists(If ifNode | 
    isMainNameCheck(ifNode) and 
    ifNode.getASubStatement().getASubStatement*() = printStatement
  )
select printStatement, "Print statement may execute during import."