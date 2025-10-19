/**
 * @name Class should be a context manager
 * @description Identifies classes implementing __del__ for resource cleanup
 *              without supporting the context manager protocol. Converting
 *              these classes to context managers improves resource management
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
  // Exclude built-in classes from analysis
  not cls.isBuiltin() and
  // Verify context manager protocol is not implemented
  not cls.isContextManager() and
  // Confirm presence of __del__ method for resource cleanup
  exists(cls.declaredAttribute("__del__"))
select cls,
  "Class " + cls.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."