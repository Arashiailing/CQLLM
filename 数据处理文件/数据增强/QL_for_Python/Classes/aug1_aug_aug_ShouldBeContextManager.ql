/**
 * @name Class should be a context manager
 * @description Detects classes that implement __del__ for resource cleanup
 *              but lack context manager support. Converting such classes to
 *              context managers improves resource handling and code clarity.
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
  // Exclude built-in classes from consideration
  not targetClass.isBuiltin() and
  // Ensure the class does not already implement the context manager protocol
  not targetClass.isContextManager() and
  // Confirm the class has a __del__ method (typically used for resource cleanup)
  exists(targetClass.declaredAttribute("__del__"))
select targetClass,
  "Class " + targetClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."