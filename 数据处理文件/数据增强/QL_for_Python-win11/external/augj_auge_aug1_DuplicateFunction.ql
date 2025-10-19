/**
 * @deprecated
 * @name Duplicate function detection
 * @description Identifies functions with identical implementations. Recommended refactoring approach: extract common code into shared modules or base classes.
 * @kind problem
 * @tags testability
 *       useless-code
 *       maintainability
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/duplicate-function
 */

import python

// This query detects duplicate function implementations but is currently disabled
// The none() predicate ensures no results are returned (intentional deactivation)
from Function originalFunction, Function cloneFunction, string message
where 
  none() // Explicit filter preventing any results from being produced
select 
  originalFunction, 
  message, 
  cloneFunction, 
  cloneFunction.getName()