/**
 * @name Print statement executed during module import
 * @description Identifies print statements located at module scope that are not protected by 
 *              `if __name__ == '__main__'` guard. These statements will be executed when the 
 *              module is imported, potentially causing unintended side effects or output.
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
predicate isMainGuardCheck(If mainGuardIf) {
  exists(Name nameVar, StringLiteral mainStrLiteral, Compare nameComparison |
    mainGuardIf.getTest() = nameComparison and
    nameComparison.getLeft() = nameVar and
    nameComparison.getAComparator() = mainStrLiteral and
    nameVar.getId() = "__name__" and
    mainStrLiteral.getText() = "__main__"
  )
}

// Identifies both Python 2 print statements and Python 3 print function calls
predicate isUnwantedPrint(Stmt statement) {
  statement instanceof Print
  or
  exists(ExprStmt expressionStatement, Call printFunctionCall, Name printFunctionName |
    expressionStatement = statement and
    printFunctionCall = expressionStatement.getValue() and
    printFunctionName = printFunctionCall.getFunc() and
    printFunctionName.getId() = "print"
  )
}

// Find print statements that execute during module import
from Stmt unprotectedPrint
where
  // Check if the statement is a print statement (Python 2 or 3)
  isUnwantedPrint(unprotectedPrint) and
  // Verify the statement is in a module scope used for imports
  exists(ModuleValue moduleImport | 
    moduleImport.getScope() = unprotectedPrint.getScope() and 
    moduleImport.isUsedAsModule()
  ) and
  // Ensure the print is not protected by a main guard
  not exists(If mainGuardIf | 
    isMainGuardCheck(mainGuardIf) and 
    mainGuardIf.getASubStatement().getASubStatement*() = unprotectedPrint
  )
select unprotectedPrint, "Print statement may execute during import."