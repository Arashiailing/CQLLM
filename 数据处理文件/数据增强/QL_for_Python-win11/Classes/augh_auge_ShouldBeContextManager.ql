/**
 * @name Class should be a context manager
 * @description Classes defining __del__ for resource cleanup should implement context manager protocol.
 *              Context managers ensure proper resource handling via 'with' statements, improving
 *              code reliability and readability through guaranteed resource release.
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
from ClassValue cls
where 
  not cls.isBuiltin() 
  and not cls.isContextManager() 
  and exists(cls.declaredAttribute("__del__"))
select 
  cls, 
  "Class " + cls.getName() + 
    " implements __del__ (presumably to release some resource). Consider making it a context manager."