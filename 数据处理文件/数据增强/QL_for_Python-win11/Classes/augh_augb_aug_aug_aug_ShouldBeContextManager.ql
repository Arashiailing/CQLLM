/**
 * @name Class should be a context manager
 * @description This query detects classes that implement __del__ for resource cleanup
 *              without supporting the context manager protocol. Transforming these
 *              classes into context managers improves resource handling and code clarity.
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
  // Focus on user-defined classes, excluding built-in types
  not targetClass.isBuiltin() and
  // Verify the presence of __del__ method for resource cleanup
  exists(targetClass.declaredAttribute("__del__")) and
  // Ensure the class doesn't implement context manager protocol
  not targetClass.isContextManager()
select targetClass,
  "Class " + targetClass.getName() +
    " implements __del__ (presumably to release some resource). Consider making it a context manager."