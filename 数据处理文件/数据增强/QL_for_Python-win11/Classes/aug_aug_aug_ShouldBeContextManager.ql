/**
 * @name Class should be a context manager
 * @description Detects classes that implement __del__ for resource cleanup
 *              but do not support the context manager protocol. Converting
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

from ClassValue resourceClass
where
  // Exclude built-in classes from our analysis scope
  not resourceClass.isBuiltin() and
  // Check that the class doesn't implement the context manager protocol
  not resourceClass.isContextManager() and
  // Verify the class has a __del__ method for resource cleanup
  exists(resourceClass.declaredAttribute("__del__"))
select resourceClass,
  "Class " + resourceClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."