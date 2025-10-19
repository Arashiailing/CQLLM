/**
 * @name Class should be a context manager
 * @description This query identifies classes that implement a __del__ method for resource cleanup
 *              but are not implemented as context managers. Converting such classes to context
 *              managers allows for more explicit resource management using 'with' statements,
 *              improving both code readability and reliability.
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

// Identify classes that would benefit from being implemented as context managers
from ClassValue targetClass
where 
  // Exclude built-in classes as they cannot be modified
  not targetClass.isBuiltin()
  and 
  // Only consider classes that are not already context managers
  not targetClass.isContextManager()
  and 
  // Focus on classes implementing __del__ method, typically for resource cleanup
  exists(targetClass.declaredAttribute("__del__"))
select targetClass, 
  "Class " + targetClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."