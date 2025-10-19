/**
 * @deprecated
 * @name Mostly similar module
 * @description Detects modules with significant code similarity. Differences in variable/type names indicate potential intentional duplication. Consolidating these modules improves maintainability.
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

from
  Module originalModule,    // Source module under analysis
  Module duplicateModule    // Module showing high similarity
select
  originalModule,
  "Modules exhibit substantial code similarity",  // Consolidated descriptive message
  duplicateModule,
  duplicateModule.getName()  // Identifier of the similar module