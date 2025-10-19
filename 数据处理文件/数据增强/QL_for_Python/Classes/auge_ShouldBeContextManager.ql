/**
 * @name Class should be a context manager
 * @description Classes that implement __del__ for resource cleanup should be context managers.
 *              Context managers enable proper resource handling via 'with' statements, enhancing
 *              code reliability and readability by ensuring resources are properly released.
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

// Identify classes that would benefit from being context managers
from ClassValue targetClass
where 
  // Exclude built-in classes as they cannot be modified
  not targetClass.isBuiltin() 
  and 
  // Focus on classes that are not already context managers
  not targetClass.isContextManager() 
  and 
  // Check if the class implements a __del__ method, suggesting resource management
  exists(targetClass.declaredAttribute("__del__"))
select 
  targetClass, 
  // Construct a helpful message suggesting the improvement
  "Class " + targetClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."