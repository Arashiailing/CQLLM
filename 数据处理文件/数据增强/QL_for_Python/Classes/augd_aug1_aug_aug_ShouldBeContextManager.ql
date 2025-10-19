/**
 * @name Class should be a context manager
 * @description Identifies classes that define a __del__ method for resource cleanup
 *              without implementing the context manager protocol. Such classes
 *              should be refactored as context managers to enhance resource management
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

from ClassValue cls
where
  // Core condition: class must have a __del__ method for resource cleanup
  exists(cls.declaredAttribute("__del__")) and
  // Exclude built-in classes from analysis scope
  not cls.isBuiltin() and
  // Ensure class doesn't already implement context manager protocol
  not cls.isContextManager()
select cls,
  "Class " + cls.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."