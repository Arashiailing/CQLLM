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

// Query identifies duplicate function implementations
// Variables represent: primary function, duplicate function, and descriptive message
from Function primaryFunction, Function duplicateFunction, string description
// Explicit filtering condition that excludes all results (no-op implementation)
where none()
// Result output: primary function, description, duplicate function, and its identifier
select primaryFunction, description, duplicateFunction, duplicateFunction.getName()