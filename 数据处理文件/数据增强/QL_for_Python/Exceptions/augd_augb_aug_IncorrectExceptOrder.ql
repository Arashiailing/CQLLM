/**
 * @name Unreachable except block
 * @description Detects except blocks that are unreachable because they are shadowed by a preceding 
 *              general exception handler. Specifically, if an except clause that catches a specific 
 *              exception (a subclass) comes after an except clause that catches its superclass, 
 *              the specific handler will never execute because the general handler catches the exception first.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

// Identify exception classes captured by exception handlers
ClassValue getHandledException(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Locate shadowed exception handlers where a general exception handler
// precedes a more specific handler in the same try statement
from ExceptStmt specificHandler, ClassValue specificEx, 
     ExceptStmt generalHandler, ClassValue generalEx,
     Try tryBlock, int generalPos, int specificPos
where
  // Both handlers belong to the same try block
  generalHandler = tryBlock.getHandler(generalPos) and
  specificHandler = tryBlock.getHandler(specificPos) and
  // General handler appears before specific handler
  generalPos < specificPos and
  // Extract handled exception types
  generalEx = getHandledException(generalHandler) and
  specificEx = getHandledException(specificHandler) and
  // General exception is superclass of specific exception
  generalEx = specificEx.getASuperType()
select specificHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificEx, specificEx.getName(), generalHandler, "except block", generalEx, generalEx.getName()