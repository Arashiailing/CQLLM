/**
 * @deprecated
 * @name Similar function detection
 * @description Identifies functions that have similar implementations. 
 *              Refactoring common code into shared functions improves maintainability.
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

// Select functions and diagnostic message
from Function mainFunction, Function similarFunction, string warningMessage
// Apply no filtering conditions
where none()
// Output main function, warning message, similar function, and its name
select mainFunction, warningMessage, similarFunction, similarFunction.getName()