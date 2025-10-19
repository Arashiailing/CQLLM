/**
 * @name Class should be a context manager
 * @description Identifies classes implementing __del__ for resource cleanup 
 *              but lacking context manager implementation. Such classes should 
 *              be refactored to support 'with' statements for explicit resource 
 *              management, enhancing code reliability and readability.
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

// Identify classes requiring context manager refactoring
from ClassValue cls
where 
  // Exclude non-modifiable built-in classes
  not cls.isBuiltin() 
  and 
  // Ensure class isn't already a context manager
  not cls.isContextManager() 
  and 
  // Check for __del__ method implementation (resource cleanup indicator)
  exists(cls.declaredAttribute("__del__"))
select cls, 
  "Class " + cls.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."