/**
 * @deprecated
 * @name Mostly duplicate class
 * @description More than 80% of the methods in this class are duplicated in another class. 
 *              Create a common supertype to improve code sharing.
 * @kind problem
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mostly-duplicate-class
 */

import python

// This query is deprecated and intentionally returns no results due to the `none()` predicate.
// It identifies potential code duplication between classes `sourceClass` and `targetClass`,
// but current implementation filters all matches through the `none()` condition.
from 
    Class sourceClass,      // Primary class being analyzed for duplication
    Class targetClass,      // Secondary class used for comparison
    string diagnosticMessage  // Detailed message describing duplication issue
where 
    none()                  // Explicitly filters all results (deprecated behavior)
select 
    sourceClass,            // Original class reference
    diagnosticMessage,      // Descriptive diagnostic message
    targetClass,            // Comparison class reference
    targetClass.getName()   // Fully qualified name of the comparison class