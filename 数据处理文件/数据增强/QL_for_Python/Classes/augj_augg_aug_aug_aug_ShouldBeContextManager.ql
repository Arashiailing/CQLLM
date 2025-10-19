/**
 * @name Class should be a context manager
 * @description Identifies classes defining a __del__ method for resource cleanup
 *              without implementing the context manager protocol. Converting these
 *              classes to context managers improves resource management and code clarity.
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

from ClassValue resourceCleanupClass
where
  // Core check: Class must define __del__ for resource cleanup
  exists(resourceCleanupClass.declaredAttribute("__del__")) and
  // Exclude built-in classes to avoid false positives
  not resourceCleanupClass.isBuiltin() and
  // Verify absence of context manager protocol implementation
  not resourceCleanupClass.isContextManager()
select resourceCleanupClass,
  "Class " + resourceCleanupClass.getName() +
    " implements __del__ (likely for resource cleanup). Consider converting to a context manager."