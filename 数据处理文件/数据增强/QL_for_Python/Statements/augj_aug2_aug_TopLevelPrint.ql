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

// Identifies main guard blocks: `if __name__ == '__main__'`
predicate isMainGuard(If guardBlock) {
  exists(Name nameVar, StringLiteral mainStr, Compare comparison |
    guardBlock.getTest() = comparison and          // Get the condition of the if statement
    comparison.getLeft() = nameVar and             // Left operand is __name__
    comparison.getAComparator() = mainStr and      // Right operand is "__main__"
    nameVar.getId() = "__name__" and               // Confirm left operand is __name__
    mainStr.getText() = "__main__"                // Confirm right operand is "__main__"
  )
}

// Identifies print operations (Python 2 print statements and Python 3 print function calls)
predicate isPrintOperation(Stmt outputStmt) {
  outputStmt instanceof Print  // Python 2 print statement
  or
  exists(ExprStmt exprStmt, Call funcCall, Name funcName |
    exprStmt = outputStmt and                      // Statement is an expression statement
    funcCall = exprStmt.getValue() and             // Get the call part of the expression
    funcName = funcCall.getFunc() and              // Get the function name being called
    funcName.getId() = "print"                     // Confirm function name is print
  )
}

// Find print statements executing during module import
from Stmt printStmt, ModuleValue moduleVal
where
  isPrintOperation(printStmt) and                   // Confirm the statement is a print operation
  // TODO: Need to discuss how we would like to handle ModuleObject.getKind in the glorious future
  moduleVal.getScope() = printStmt.getScope() and 
  moduleVal.isUsedAsModule() and                   // Check if the statement is in an imported module
  not exists(If guardBlock | 
    isMainGuard(guardBlock) and 
    guardBlock.getASubStatement().getASubStatement*() = printStmt  // Ensure not inside main guard
  )
select printStmt, "Print statement may execute during import."