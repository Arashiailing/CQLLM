/**
 * @name Class should be a context manager
 * @description Detects classes that define __del__ for resource cleanup
 *              but do not implement the context manager protocol. Such classes
 *              would benefit from being converted to context managers for better
 *              resource handling and improved code maintainability.
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

from ClassValue targetClass
where
  // Exclude built-in classes from our analysis
  not targetClass.isBuiltin() and
  // Check that the class does not follow the context manager protocol
  not targetClass.isContextManager() and
  // Ensure the class has a __del__ method, typically used for resource cleanup
  exists(targetClass.declaredAttribute("__del__"))
select targetClass,
  "Class " + targetClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."