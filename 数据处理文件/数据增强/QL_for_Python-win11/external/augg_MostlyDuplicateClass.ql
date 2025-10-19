/**
 * @deprecated
 * @name Mostly duplicate class
 * @description Identifies classes with over 80% method duplication in another class. 
 *              Creating a common supertype is recommended to improve code sharing.
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

// Define source variables for class comparison
from 
  Class targetClass,     // Primary class being analyzed
  Class sourceClass,     // Class to compare against
  string notification    // Result notification message
where 
  none()                 // No filtering applied (preserves original logic)
select 
  targetClass,           // First element: analyzed class
  notification,          // Second element: result message
  sourceClass,           // Third element: comparison class
  sourceClass.getName()  // Fourth element: comparison class name