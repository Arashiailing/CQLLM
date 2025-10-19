/**
 * @deprecated This query is deprecated and currently returns no results.
 * @name Similar Function
 * @description Detects functions that are very similar to each other. It is recommended to extract the common code into a shared function to improve code sharing and maintainability.
 * @kind problem
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity low
 * @precision very-high
 * @id py/similar-function
 */

import python

// Declare variables for source function, comparison function, and message
from Function funcA, Function funcB, string msg
// Placeholder condition that intentionally yields no results
where none()
// Output source function, message, comparison function, and its name
select 
  funcA, 
  msg, 
  funcB, 
  funcB.getName()