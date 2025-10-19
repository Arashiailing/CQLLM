/**
 * @name Print statement execution during module import
 * @description Detects print statements at module scope that execute during import without proper guarding,
 *              which can lead to unintended side effects when the module is imported by other code.
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

// Identifies if statements that serve as entry point guards using the pattern `if __name__ == '__main__'`
predicate isMainGuard(If guardStmt) {
  exists(Name nameNode, StringLiteral mainLiteral, Compare comparisonNode |
    guardStmt.getTest() = comparisonNode and        // The condition of the if statement
    comparisonNode.getLeft() = nameNode and         // Left operand must be __name__
    comparisonNode.getAComparator() = mainLiteral and // Right operand must be "__main__"
    nameNode.getId() = "__name__" and               // Confirm left operand is __name__
    mainLiteral.getText() = "__main__"              // Confirm right operand is "__main__"
  )
}

// Detects both Python 2 print statements and Python 3 print function calls
predicate isPrintOperation(Stmt targetStmt) {
  targetStmt instanceof Print  // Python 2 print statement
  or
  exists(ExprStmt expressionStmt, Call functionCall, Name functionName |
    expressionStmt = targetStmt and             // Statement is an expression statement
    functionCall = expressionStmt.getValue() and // Extract the call expression
    functionName = functionCall.getFunc() and   // Get the function being called
    functionName.getId() = "print"              // Verify it's the print function
  )
}

// Locate print statements that execute during module import
from Stmt printOperation
where
  isPrintOperation(printOperation) and          // Verify the statement is a print operation
  // Ensure the statement is within a module that gets imported
  exists(ModuleValue importedModule | 
    importedModule.getScope() = printOperation.getScope() and 
    importedModule.isUsedAsModule()             // Module is imported by other code
  ) and
  // Verify the print is not protected by a main guard
  not exists(If mainGuard | 
    isMainGuard(mainGuard) and 
    mainGuard.getASubStatement().getASubStatement*() = printOperation
  )
select printOperation, "Print statement may execute during import."