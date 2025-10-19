/**
 * @deprecated
 * @name Substantial module similarity detection
 * @description Identifies modules exhibiting substantial code similarity. Note that variable names and data types may differ between modules. Consolidation is recommended for enhanced maintainability.
 * @kind problem
 * @problem.severity recommendation
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @sub-severity low
 * @precision high
 * @id py/mostly-similar-file
 */

import python

// Declare source module, target module, and similarity rationale
from Module sourceModule, 
     Module targetModule, 
     string similarityRationale

// Apply similarity detection constraints (currently inactive)
where none()

// Output source module, similarity rationale, target module, and its name
select 
  sourceModule, 
  similarityRationale, 
  targetModule, 
  targetModule.getName()