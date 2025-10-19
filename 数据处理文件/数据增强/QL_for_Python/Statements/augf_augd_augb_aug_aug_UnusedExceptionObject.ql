/**
 * @name Unused exception object
 * @description Identifies exception instances that are created but never used,
 *              suggesting potential programming mistakes or redundant code that should be eliminated.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for analyzing Python source code

// Find exception object instantiations that are never utilized
from Call exceptionCreation, ClassValue exceptionClass
where
  // Ensure the call instantiates an exception class
  exceptionCreation.getFunc().pointsTo(exceptionClass) and
  // Verify the class inherits from Exception
  exceptionClass.getASuperType() = ClassValue::exception() and
  // Check if the exception object appears only as a standalone expression statement
  exists(ExprStmt unusedStatement | 
    unusedStatement.getValue() = exceptionCreation
  )
select exceptionCreation, "Exception object created but not used. Consider raising the exception or removing this statement."