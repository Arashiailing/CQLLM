/**
 * @name Class should be a context manager
 * @description Identifies classes that define a __del__ method for resource cleanup
 *              but lack the context manager protocol implementation. Such classes
 *              would benefit from being converted to context managers, improving
 *              resource management and code readability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision medium
 * @id py/should-be-context-manager
 */

import python

from ClassValue delClass
where
  // Ensure the class is not a built-in class
  not delClass.isBuiltin() and
  // Verify the class has a __del__ method for resource cleanup
  exists(delClass.declaredAttribute("__del__")) and
  // Check that the class doesn't implement the context manager protocol
  not delClass.isContextManager()
select delClass,
  "Class " + delClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."