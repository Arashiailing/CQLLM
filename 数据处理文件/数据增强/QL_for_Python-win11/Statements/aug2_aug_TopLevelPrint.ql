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
predicate isMainGuard(If ifNode) {
  exists(Name nameNode, StringLiteral mainLiteral, Compare comparisonExpr |
    ifNode.getTest() = comparisonExpr and          // Get the condition of the if statement
    comparisonExpr.getLeft() = nameNode and        // Left operand is __name__
    comparisonExpr.getAComparator() = mainLiteral and // Right operand is "__main__"
    nameNode.getId() = "__name__" and              // Confirm left operand is __name__
    mainLiteral.getText() = "__main__"             // Confirm right operand is "__main__"
  )
}

// Identifies print statements (both Python 2 print statements and Python 3 print function calls)
predicate isPrintOperation(Stmt statement) {
  statement instanceof Print  // Python 2 print statement
  or
  exists(ExprStmt exprStatement, Call functionCall, Name functionName |
    exprStatement = statement and                  // Statement is an expression statement
    functionCall = exprStatement.getValue() and    // Get the call part of the expression
    functionName = functionCall.getFunc() and      // Get the function name being called
    functionName.getId() = "print"                 // Confirm function name is print
  )
}

// Find print statements that execute during module import
from Stmt printStatement
where
  isPrintOperation(printStatement) and             // Confirm the statement is a print statement
  // TODO: Need to discuss how we would like to handle ModuleObject.getKind in the glorious future
  exists(ModuleValue moduleValue | 
    moduleValue.getScope() = printStatement.getScope() and 
    moduleValue.isUsedAsModule()                   // Check if the statement is in a module that is used as an imported module
  ) and
  not exists(If ifNode | 
    isMainGuard(ifNode) and 
    ifNode.getASubStatement().getASubStatement*() = printStatement  // Ensure the print statement is not inside an if __name__ == '__main__' block
  )
select printStatement, "Print statement may execute during import."