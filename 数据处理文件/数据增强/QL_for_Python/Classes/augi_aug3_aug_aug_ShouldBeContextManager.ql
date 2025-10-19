/**
 * @name Class should be a context manager
 * @description Identifies classes that use __del__ for resource management
 *              but lack context manager protocol support. Such classes would
 *              benefit from implementing the context manager pattern to improve
 *              resource handling and code readability.
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

from ClassValue resourceClass
where
  // Focus on user-defined classes, excluding built-in ones
  not resourceClass.isBuiltin()
  and
  // Check for presence of __del__ method, typically used for resource cleanup
  exists(resourceClass.declaredAttribute("__del__"))
  and
  // Verify the class does not implement the context manager protocol
  not resourceClass.isContextManager()
select resourceClass,
  "Class " + resourceClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."