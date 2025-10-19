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

// Identify classes that should be converted to context managers
from ClassValue resourceClass
where
  // Filter for user-defined classes only (exclude built-in classes)
  not resourceClass.isBuiltin() and
  // Check if the class has a __del__ method (indicating resource management)
  exists(resourceClass.declaredAttribute("__del__")) and
  // Exclude classes that already implement the context manager protocol
  not resourceClass.isContextManager()
select resourceClass,
  "Class " + resourceClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."