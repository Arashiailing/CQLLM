/**
 * @name Class should be a context manager
 * @description Detects classes that implement __del__ for resource cleanup
 *              but aren't implemented as context managers. Converting these
 *              classes to context managers enables more explicit resource
 *              management using 'with' statements, enhancing code readability
 *              and reliability.
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

// Find classes that would benefit from context manager implementation
from ClassValue problematicClass
where 
  // Skip built-in classes since they cannot be modified
  not problematicClass.isBuiltin()
  and 
  // Only examine classes that are not already context managers
  not problematicClass.isContextManager()
  and 
  // Target classes that implement __del__ method, typically for cleanup
  exists(problematicClass.declaredAttribute("__del__"))
select problematicClass, 
  "Class " + problematicClass.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."