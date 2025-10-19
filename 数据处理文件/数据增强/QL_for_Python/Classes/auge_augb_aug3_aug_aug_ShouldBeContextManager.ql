/**
 * @name Class should be a context manager
 * @description Identifies classes that implement __del__ for resource cleanup
 *              but lack context manager protocol support. Such classes would
 *              benefit from being converted to context managers for improved
 *              resource handling and code readability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision medium
 * @id py/should-be-context-manager */

import python

from ClassValue resourceCleanupClass
where
  // Filter for user-defined classes (excluding built-in ones)
  not resourceCleanupClass.isBuiltin() and
  // Check if class implements __del__ method for resource management
  exists(resourceCleanupClass.declaredAttribute("__del__")) and
  // Exclude classes that already support the context manager protocol
  not resourceCleanupClass.isContextManager()
select resourceCleanupClass,
  "Class " + resourceCleanupClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."