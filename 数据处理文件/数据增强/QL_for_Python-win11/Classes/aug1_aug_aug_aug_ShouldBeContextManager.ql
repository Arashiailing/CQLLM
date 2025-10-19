/**
 * @name Class should be a context manager
 * @description Detects classes that implement __del__ for resource cleanup
 *              but don't support the context manager protocol. Converting
 *              such classes to context managers enhances resource management
 *              and code clarity.
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
  // Skip built-in classes since they're outside our analysis scope
  not cls.isBuiltin() and
  // Identify classes lacking context manager protocol support
  not cls.isContextManager() and
  // Detect presence of __del__ method for resource cleanup
  exists(cls.declaredAttribute("__del__"))
select cls,
  "Class " + cls.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."