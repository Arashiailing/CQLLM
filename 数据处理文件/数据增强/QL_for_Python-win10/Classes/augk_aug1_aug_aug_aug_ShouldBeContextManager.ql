/**
 * @name Class should be a context manager
 * @description Identifies classes that have a __del__ method for resource cleanup
 *              yet lack the context manager protocol. Transforming these classes
 *              into context managers improves resource handling and code readability.
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
  // Check for presence of __del__ method indicating resource cleanup logic
  exists(cls.declaredAttribute("__del__")) and
  // Exclude built-in classes from analysis scope
  not cls.isBuiltin() and
  // Verify absence of context manager protocol implementation
  not cls.isContextManager()
select cls,
  "Class " + cls.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."