/**
 * @name Class should be a context manager
 * @description Identifies classes that define a __del__ method for resource cleanup
 *              but do not adhere to the context manager protocol. Such classes
 *              would benefit from implementing the context manager interface to
 *              improve resource management and code readability.
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
  // Primary condition: The class must define a __del__ method for resource cleanup
  exists(cleanupClass.declaredAttribute("__del__")) and
  // Exclusion criteria: The class should not be a built-in
  not cleanupClass.isBuiltin() and
  // Negative condition: The class must not already implement the context manager protocol
  not cleanupClass.isContextManager()
select cleanupClass,
  "Class " + cleanupClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."