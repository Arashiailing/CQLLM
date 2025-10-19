/**
 * @name Duplicate function
 * @description Detects functions with identical implementations. Consider refactoring by extracting shared code into common modules or base classes.
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

// Core analysis variables for duplicate function detection
from Function func1, Function func2, string message
where 
  // Ensure distinct functions with identical implementations
  func1 != func2 and
  exists(
    string body1, string body2 |
    body1 = func1.getBody().toString().replaceAll("\\s+", "") and
    body2 = func2.getBody().toString().replaceAll("\\s+", "") and
    body1 = body2
  ) and
  // Prevent duplicate reporting by enforcing position ordering
  func1.getLocation().toString() < func2.getLocation().toString() and
  // Set diagnostic message
  message = "Function has duplicate implementation"
// Output format: original function, diagnostic message, duplicate function, and its name
select 
  func1, 
  message, 
  func2, 
  func2.getName()