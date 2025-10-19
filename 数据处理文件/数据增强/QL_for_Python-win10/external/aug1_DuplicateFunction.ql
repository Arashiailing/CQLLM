/**
 * @deprecated
 * @name Duplicate function
 * @description Identical function implementation detected. Refactor by extracting common code to shared modules or base classes.
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

// Select primary function, duplicate function, and descriptive message
from Function func1, Function func2, string msg
// Explicitly filter out all results (no-op condition)
where none()
// Output: primary function, message, duplicate function, and its name
select func1, msg, func2, func2.getName()