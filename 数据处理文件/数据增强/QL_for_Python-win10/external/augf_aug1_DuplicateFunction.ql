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

// Define source functions and message variable
from Function primaryFunc, Function duplicateFunc, string description
// Apply no-op condition to filter all results
where none()
// Output: primary function, description, duplicate function, and its name
select primaryFunc, description, duplicateFunc, duplicateFunc.getName()