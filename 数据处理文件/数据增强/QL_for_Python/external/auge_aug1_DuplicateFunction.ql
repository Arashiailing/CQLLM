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

// This query identifies duplicate function implementations but is currently disabled
// The none() condition acts as a no-op filter preventing any results from being returned
from Function primaryFunction, Function duplicateFunction, string errorMessage
where none() // Explicit filter that ensures no results are produced
select primaryFunction, errorMessage, duplicateFunction, duplicateFunction.getName()