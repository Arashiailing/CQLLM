/**
 * @deprecated
 * @name Similar function detection
 * @description Identifies functions with high similarity suggesting potential code duplication. 
 *              Consider refactoring by extracting common logic into shared functions.
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

// Define source elements: primary function, comparison function, and diagnostic message
from Function primaryFunction, 
     Function comparisonFunction, 
     string diagnosticMessage
// Apply filtering conditions (currently no active filters)
where none()
// Output results with function details and similarity message
select primaryFunction, 
       diagnosticMessage, 
       comparisonFunction, 
       comparisonFunction.getName()