/**
 * @deprecated
 * @name Duplicate function
 * @description Detects functions with identical implementations. Code duplication should be eliminated by extracting common logic to shared modules or base classes.
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

// Select candidate functions and their duplicates with descriptive message
from Function primaryFunc, Function duplicateFunc, string description
// No filtering applied (deprecated implementation)
where none()
// Return primary function, description, duplicate function, and its name
select primaryFunc, description, duplicateFunc, duplicateFunc.getName()