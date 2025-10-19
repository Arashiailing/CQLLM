/**
 * @name Unused exception object
 * @description Detects instances where an exception object is created but never utilized,
 *              which may indicate programming errors or unnecessary code that should be removed.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for analyzing Python source code

// Identify locations where exception objects are instantiated without being utilized
from Call exceptionInstantiation, ClassValue exceptionType
where
  // First, verify the call creates an instance of an exception class
  exceptionInstantiation.getFunc().pointsTo(exceptionType) and
  // Next, confirm the class is Exception or one of its subclasses
  exceptionType.getASuperType() = ClassValue::exception() and
  // Finally, check if the exception object exists only as a standalone statement
  exists(ExprStmt standaloneStatement | 
    standaloneStatement.getValue() = exceptionInstantiation
  )
select exceptionInstantiation, "Exception object created but not used. Consider raising the exception or removing this statement."