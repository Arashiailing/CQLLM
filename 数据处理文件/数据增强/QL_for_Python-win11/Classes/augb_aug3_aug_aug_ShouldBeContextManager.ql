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
 * @id py/should-be-context-manager
 */

import python

from ClassValue cls
where
  // Focus on user-defined classes that manage resources via __del__
  not cls.isBuiltin() and
  exists(cls.declaredAttribute("__del__")) and
  // Exclude classes that already implement context manager protocol
  not cls.isContextManager()
select cls,
  "Class " + cls.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."