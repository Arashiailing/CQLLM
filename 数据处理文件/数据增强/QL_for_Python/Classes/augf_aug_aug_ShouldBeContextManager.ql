/**
 * @name Class should be a context manager
 * @description Detects classes that implement __del__ for resource cleanup
 *              but lack context manager support. Refactoring such classes
 *              as context managers enhances resource management and code clarity.
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
  // Exclude built-in classes from analysis scope
  not targetClass.isBuiltin() and
  // Ensure the class doesn't implement the context manager protocol
  not targetClass.isContextManager() and
  // Confirm presence of __del__ method for resource cleanup
  exists(targetClass.declaredAttribute("__del__"))
select targetClass,
  "Class " + targetClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."