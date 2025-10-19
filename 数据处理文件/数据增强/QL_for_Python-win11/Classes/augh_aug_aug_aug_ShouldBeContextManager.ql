/**
 * @name Class should be a context manager
 * @description Identifies classes that implement __del__ for resource cleanup
 *              but lack context manager protocol support. Such classes should
 *              be converted to context managers for improved resource management
 *              and code readability.
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

from ClassValue cleanupClass
where
  // Focus on user-defined classes only
  not cleanupClass.isBuiltin() and
  // Identify classes with resource cleanup logic
  exists(cleanupClass.declaredAttribute("__del__")) and
  // Filter out classes that already support context management
  not cleanupClass.isContextManager()
select cleanupClass,
  "Class " + cleanupClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."