/**
 * @deprecated
 * @name Similar function
 * @description There is another function that is very similar this one. Extract the common code to a common function to improve sharing.
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

// Selects source function, comparison function, and message string
from Function sourceFunc, Function comparisonFunc, string message
// Condition intentionally returns no results (placeholder implementation)
where none()
// Outputs source function, message, comparison function, and comparison function's name
select sourceFunc, message, comparisonFunc, comparisonFunc.getName()