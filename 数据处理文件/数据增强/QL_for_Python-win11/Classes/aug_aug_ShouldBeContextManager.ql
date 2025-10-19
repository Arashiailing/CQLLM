/**
 * @name Class should be a context manager
 * @description Identifies classes implementing __del__ for resource cleanup
 *              that lack context manager support. Refactoring such classes
 *              as context managers improves resource handling and readability.
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
  // Filter out built-in classes from analysis scope
  not cls.isBuiltin() and
  // Verify class lacks context manager implementation
  not cls.isContextManager() and
  // Confirm presence of resource cleanup method
  exists(cls.declaredAttribute("__del__"))
select cls,
  "Class " + cls.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."