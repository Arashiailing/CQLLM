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

// This deprecated query intentionally returns no results via the `none()` predicate.
// It identifies potential code duplication between classes `primaryClass` and `secondaryClass`,
// but current implementation filters all matches through the `none()` condition.
from 
    Class primaryClass,      // Primary class being analyzed for duplication
    Class secondaryClass,    // Secondary class used for comparison
    string issueDescription  // Detailed message describing duplication issue
where 
    none()                  // Explicitly filters all results (deprecated behavior)
select 
    primaryClass,           // Original class reference
    issueDescription,       // Descriptive diagnostic message
    secondaryClass,         // Comparison class reference
    secondaryClass.getName() // Fully qualified name of the comparison class