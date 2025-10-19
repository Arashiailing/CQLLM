/**
 * @name Class should be a context manager
 * @description Identifies classes that implement __del__ for resource cleanup but lack context manager support.
 *              These classes should implement the context manager protocol (__enter__ and __exit__)
 *              to enable proper resource handling via 'with' statements, enhancing code reliability
 *              and readability by ensuring resources are properly released.
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

// Find classes that implement __del__ but aren't context managers
from ClassValue resourceManagingClass
where 
  // Exclude built-in classes as they cannot be modified
  not resourceManagingClass.isBuiltin() 
  and 
  // Focus on classes that are not already context managers
  not resourceManagingClass.isContextManager() 
  and 
  // Check if the class implements a __del__ method, suggesting resource management
  exists(resourceManagingClass.declaredAttribute("__del__"))
select 
  resourceManagingClass, 
  // Construct a helpful message suggesting the improvement
  "Class " + resourceManagingClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."