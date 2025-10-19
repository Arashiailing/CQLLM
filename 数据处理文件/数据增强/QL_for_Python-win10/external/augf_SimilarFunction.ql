/**
 * @deprecated
 * @name Similar function
 * @description Identifies function pairs that should be refactored due to high similarity. Note: This query is deprecated and does not implement actual similarity detection.
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

// Select function pairs with placeholder description
from Function funcA, Function funcB, string description
where 
  // Assign deprecation notice as description
  description = "Deprecated: Similarity detection not implemented" 
  // Original empty condition removed (none() was always false)
select 
  funcA, 
  description, 
  funcB, 
  funcB.getName()