/**
 * @deprecated
 * @name Mostly duplicate class
 * @description More than 80% of the methods in this class are duplicated in another class. Create a common supertype to improve code sharing.
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

// Select source class, duplicate class, description message, and duplicate class name
from 
    Class sourceClass, 
    Class duplicateClass, 
    string description
where 
    none()  // No filtering conditions applied
select 
    sourceClass, 
    description, 
    duplicateClass, 
    duplicateClass.getName()