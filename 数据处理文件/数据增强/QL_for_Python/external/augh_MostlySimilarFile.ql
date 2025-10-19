/**
 * @deprecated
 * @name Mostly similar module
 * @description Identifies modules that share significant code similarity with other modules.
 *              Variable and type names may differ, but the underlying logic is similar.
 *              Consider merging these modules to enhance code maintainability.
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

// Define variables for source module, target module, and similarity message
from Module sourceModule, Module targetModule, string similarityMessage
where 
  // No filtering condition applied - processes all module pairs
  none()
select 
  // Output the source module, similarity message, target module, and target module name
  sourceModule, 
  similarityMessage, 
  targetModule, 
  targetModule.getName()