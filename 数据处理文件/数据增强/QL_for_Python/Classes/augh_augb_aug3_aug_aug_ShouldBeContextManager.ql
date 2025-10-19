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

from ClassValue resourceClass
where
  // Target custom classes that define __del__ for resource management
  not resourceClass.isBuiltin() and
  exists(resourceClass.declaredAttribute("__del__")) and
  // Exclude classes already implementing context manager protocol
  not resourceClass.isContextManager()
select resourceClass,
  "Class " + resourceClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."