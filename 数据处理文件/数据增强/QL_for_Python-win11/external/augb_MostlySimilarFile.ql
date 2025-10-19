/**
 * @deprecated
 * @name Mostly similar module
 * @description Identifies modules sharing substantial code similarity. Variable/type name differences suggest intentional duplication. Merge these modules to enhance maintainability.
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
  Module primaryModule,    // Primary module being analyzed
  Module duplicateModule,  // Module showing high similarity
  string alertMessage     // Descriptive alert message
where
  none()                  // Placeholder condition (no filtering applied)
select
  primaryModule,
  alertMessage,
  duplicateModule,
  duplicateModule.getName()  // Name of the similar module