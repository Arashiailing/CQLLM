/**
 * @name Class should be a context manager
 * @description Detects classes that define a __del__ method for resource cleanup
 *              without implementing the context manager protocol. Such classes would
 *              benefit from being refactored as context managers, enabling more explicit
 *              resource handling through 'with' statements, thereby enhancing code clarity
 *              and robustness.
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

// Define our main candidate for context manager conversion
from ClassValue candidateClass
where 
  // Filter out system classes that cannot be modified
  not candidateClass.isBuiltin()
  and 
  // Ensure the class is not already implementing the context manager interface
  not candidateClass.isContextManager()
  and 
  // Check for presence of __del__ method, indicating resource cleanup logic
  exists(candidateClass.declaredAttribute("__del__"))
select candidateClass, 
  "Class " + candidateClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."