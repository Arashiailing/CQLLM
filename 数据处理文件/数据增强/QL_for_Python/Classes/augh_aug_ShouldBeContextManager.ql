/**
 * @name Class should be a context manager
 * @description Identifies classes implementing __del__ for resource cleanup
 *              but not as context managers. Converting to context managers
 *              enables explicit resource management via 'with' statements,
 *              enhancing code readability and reliability.
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

// Find classes that implement __del__ for resource cleanup
// but are not context managers and could benefit from being one
from ClassValue resourceClass
where 
  // Check if the class has a __del__ method
  exists(resourceClass.declaredAttribute("__del__"))
  and 
  // Ensure it's not a built-in class (which cannot be modified)
  not resourceClass.isBuiltin()
  and 
  // Verify it's not already a context manager
  not resourceClass.isContextManager()
select resourceClass, 
  "Class " + resourceClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."