/**
 * @name Class should be a context manager
 * @description Finds classes that have a __del__ method (often used for resource cleanup)
 *              but do not implement the context manager protocol. Such classes would benefit
 *              from being refactored as context managers, enabling more predictable resource
 *              management through 'with' statements and enhancing code clarity and robustness.
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
from ClassValue candidateClass
where 
  // Exclude built-in classes as they cannot be modified
  not candidateClass.isBuiltin()
  and 
  // Only consider classes that are not already context managers
  not candidateClass.isContextManager()
  and 
  // Focus on classes implementing __del__ method, typically for resource cleanup
  exists(candidateClass.declaredAttribute("__del__"))
select candidateClass, 
  "Class " + candidateClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."