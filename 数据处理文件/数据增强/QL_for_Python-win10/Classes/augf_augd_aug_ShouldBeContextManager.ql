/**
 * @name Class should be a context manager
 * @description Identifies classes that implement a __del__ method for resource cleanup
 *              but do not adhere to the context manager protocol. These classes are prime
 *              candidates for refactoring into context managers, which would enable more
 *              explicit resource management via 'with' statements. This transformation
 *              enhances code clarity, reduces resource leak risks, and follows Python's
 *              best practices for resource handling.
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

// Identify classes that could benefit from being context managers
from ClassValue resourceCleanupClass
where 
  // First, filter out classes that cannot be modified
  not resourceCleanupClass.isBuiltin()
  and 
  // Next, ensure the class doesn't already implement the context manager interface
  not resourceCleanupClass.isContextManager()
  and 
  // Finally, verify the presence of a __del__ method, suggesting resource cleanup logic
  exists(resourceCleanupClass.declaredAttribute("__del__"))
select resourceCleanupClass, 
  "Class " + resourceCleanupClass.getName() + 
    " implements __del__ (likely for resource cleanup). Consider refactoring it as a context manager to improve resource management."