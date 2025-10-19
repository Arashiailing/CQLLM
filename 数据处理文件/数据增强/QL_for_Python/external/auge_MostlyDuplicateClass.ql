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

// This query intentionally returns no results due to the `none()` predicate.
// It identifies classes `c` and `other` with a descriptive `message`,
// but current implementation filters out all matches.
from 
    Class c,           // Source class being analyzed
    Class other,       // Target class for comparison
    string message     // Diagnostic message describing duplication
where 
    none()             // Explicitly filters all results (deprecated behavior)
select 
    c,                 // Original class reference
    message,           // Descriptive message
    other,             // Comparison class reference
    other.getName()    // Qualified name of the comparison class