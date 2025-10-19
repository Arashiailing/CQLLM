/**
 * @name Unused exception object
 * @description Detects instances where an exception object is created but not used,
 *              which may indicate programming mistakes or unnecessary code.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Python module for code analysis

// Identify locations where exception objects are instantiated but never utilized
from Call exceptionInstantiation, ClassValue exceptionType, ExprStmt standaloneExpr
where
  // The call instantiates an exception class
  exceptionInstantiation.getFunc().pointsTo(exceptionType) and
  // The class is a subclass of Exception
  exceptionType.getASuperType() = ClassValue::exception() and
  // The exception object is created but not used
  standaloneExpr.getValue() = exceptionInstantiation

select exceptionInstantiation, "Exception object created but not used. Consider raising the exception or removing this statement."