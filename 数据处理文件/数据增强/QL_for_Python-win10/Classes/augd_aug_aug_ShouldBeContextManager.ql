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

from ClassValue resourceClass
where
  // Exclude built-in classes from analysis scope
  not resourceClass.isBuiltin() and
  // Verify absence of context manager implementation
  not resourceClass.isContextManager() and
  // Confirm presence of resource cleanup method
  exists(resourceClass.declaredAttribute("__del__"))
select resourceClass,
  "Class " + resourceClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."