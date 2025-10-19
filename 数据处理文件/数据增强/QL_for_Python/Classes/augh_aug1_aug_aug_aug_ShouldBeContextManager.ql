/**
 * @name Class should be a context manager
 * @description Identifies classes that implement __del__ for resource cleanup
 *              but lack context manager protocol support. Such classes should
 *              be converted to context managers to improve resource management
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

from ClassValue resourceClass
where
  // Exclude built-in classes from analysis scope
  not resourceClass.isBuiltin() and
  // Identify classes that don't implement the context manager protocol
  not resourceClass.isContextManager() and
  // Check for presence of __del__ method which typically handles resource cleanup
  exists(resourceClass.declaredAttribute("__del__"))
select resourceClass,
  "Class " + resourceClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."