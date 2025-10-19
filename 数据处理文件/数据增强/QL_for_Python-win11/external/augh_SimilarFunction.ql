/**
 * @deprecated
 * @name Similar function
 * @description This function has significant similarity with another function. Consider extracting common code into a shared utility function to enhance maintainability and reduce duplication.
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

// Define source variables: primary function, similar function, and description message
from Function primaryFunc, Function similarFunc, string description
// Apply empty filter condition (no results returned)
where none()
// Output analysis results with consistent formatting
select primaryFunc, description, similarFunc, similarFunc.getName()