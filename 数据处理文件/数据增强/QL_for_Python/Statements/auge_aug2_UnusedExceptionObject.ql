/**
 * @name Unused exception object
 * @description Identifies exception objects that are created but never utilized (e.g., raised or caught).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python

from Call unusedExcCall, ClassValue excType
where
  // Verify the call targets an exception class
  unusedExcCall.getFunc().pointsTo(excType) and
  // Ensure the exception type inherits from base Exception
  excType.getASuperType() = ClassValue::exception() and
  // Confirm the exception is instantiated but never used
  exists(ExprStmt exprStmt | exprStmt.getValue() = unusedExcCall)
select unusedExcCall, "Creating an exception instance without raising it serves no purpose."