/**
 * @name Class should be a context manager
 * @description Detects classes that implement __del__ for resource management
 *              but do not support the context manager protocol. Converting these
 *              classes to context managers would enhance resource handling
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

from ClassValue targetClass
where
  // Exclude built-in classes from our analysis
  not targetClass.isBuiltin() and
  // Check if the class defines a __del__ method for resource cleanup
  exists(targetClass.declaredAttribute("__del__")) and
  // Ensure the class does not already implement the context manager protocol
  not targetClass.isContextManager()
select targetClass,
  "Class " + targetClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."