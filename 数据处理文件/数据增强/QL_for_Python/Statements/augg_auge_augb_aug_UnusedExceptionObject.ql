/**
 * @name Unused exception object
 * @description Detects exception instances that are created but never used.
 *              Creating an exception instance without raising it or utilizing it
 *              for any purpose typically indicates a programming error.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python

from Call exceptionInstance, ClassValue exceptionType
where
  // Condition 1: The call targets an exception class
  exceptionInstance.getFunc().pointsTo(exceptionType) and
  // Condition 2: The class is a subclass of Python's base exception
  exceptionType.getASuperType() = ClassValue::exception() and
  // Condition 3: The exception is only used as a standalone statement
  exists(ExprStmt isolatedStatement | 
    isolatedStatement.getValue() = exceptionInstance
  )
select exceptionInstance, "Instantiating an exception, but not raising it, has no effect."