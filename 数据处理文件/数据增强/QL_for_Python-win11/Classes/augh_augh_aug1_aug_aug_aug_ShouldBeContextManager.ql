/**
 * @name Class should be a context manager
 * @description Detects classes that implement __del__ for resource cleanup
 *              without supporting the context manager protocol. These classes
 *              should be refactored as context managers to enhance resource
 *              management and code maintainability.
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
  // Check if the class has a __del__ method for resource cleanup
  exists(cleanupClass.declaredAttribute("__del__")) and
  // Exclude built-in classes from consideration
  not cleanupClass.isBuiltin() and
  // Ensure the class doesn't already implement context manager protocol
  not cleanupClass.isContextManager()
select cleanupClass,
  "Class " + cleanupClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."