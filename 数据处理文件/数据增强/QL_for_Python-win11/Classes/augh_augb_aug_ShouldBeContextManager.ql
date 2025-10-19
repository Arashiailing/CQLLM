/**
 * @name Class should be a context manager
 * @description Detects classes that implement a __del__ method for resource cleanup
 *              but are not implemented as context managers. Such classes should be
 *              converted to context managers to enable explicit resource management
 *              using 'with' statements, which enhances code readability and reliability.
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

// Identify classes requiring context manager implementation
from ClassValue targetClass
where 
  // Exclude built-in classes as they cannot be modified
  not targetClass.isBuiltin()
  and 
  // Ensure the class isn't already a context manager
  not targetClass.isContextManager()
  and 
  // Check for __del__ method presence indicating resource cleanup
  exists(targetClass.declaredAttribute("__del__"))
select targetClass, 
  "Class " + targetClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."