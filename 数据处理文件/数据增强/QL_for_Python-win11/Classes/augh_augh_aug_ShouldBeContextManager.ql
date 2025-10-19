/**
 * @name Class should be a context manager
 * @description Detects classes that define __del__ for resource cleanup
 *              but do not implement the context manager protocol. Such classes
 *              should be refactored to support the 'with' statement for more
 *              explicit and reliable resource management.
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

// Identify classes that implement __del__ for resource cleanup
// but are not context managers and could benefit from being one
from ClassValue delClass
where 
  // Class has a __del__ method, indicating resource cleanup logic
  exists(delClass.declaredAttribute("__del__"))
  and 
  // Exclude built-in classes as they cannot be modified
  not delClass.isBuiltin()
  and 
  // Ensure the class is not already a context manager
  not delClass.isContextManager()
select delClass, 
  "Class " + delClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."