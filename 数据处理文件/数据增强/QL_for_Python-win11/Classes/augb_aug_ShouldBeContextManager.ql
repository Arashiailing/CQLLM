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

// Find classes that would benefit from being implemented as context managers
from ClassValue subjectClass
where 
  // Skip built-in classes since they cannot be modified
  not subjectClass.isBuiltin()
  and 
  // Only consider classes that are not already context managers
  not subjectClass.isContextManager()
  and 
  // Target classes that implement __del__ method, typically used for resource cleanup
  exists(subjectClass.declaredAttribute("__del__"))
select subjectClass, 
  "Class " + subjectClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."