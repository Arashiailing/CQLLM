/**
 * @deprecated
 * @name Similar function detection
 * @description Identifies functions that have significant code similarity with other functions. Refactoring shared logic into common functions improves maintainability and reduces duplication.
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

// Define source elements: primary function, similar function, and description message
from Function primaryFunc, Function similarFunc, string description
// Apply filtering condition (currently none for demonstration purposes)
where none()
// Output results including: primary function, description, similar function, and its name
select primaryFunc, description, similarFunc, similarFunc.getName()