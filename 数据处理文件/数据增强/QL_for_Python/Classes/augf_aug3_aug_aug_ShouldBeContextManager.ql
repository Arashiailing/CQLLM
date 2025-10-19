/**
 * @name Class should be a context manager
 * @description Identifies classes implementing __del__ for resource management
 *              without supporting the context manager protocol. Converting these
 *              classes to context managers improves resource handling and code clarity.
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
  // Core condition: Class defines __del__ for resource cleanup
  exists(cls.declaredAttribute("__del__")) and
  // Filter out built-in classes from analysis scope
  not cls.isBuiltin() and
  // Verify class lacks context manager protocol implementation
  not cls.isContextManager()
select cls,
  "Class " + cls.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."