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
  Module baseModule,     // Primary module being analyzed
  Module matchedModule,  // Module showing high similarity
  string notification    // Descriptive alert message
where
  none()                 // Placeholder condition (no filtering applied)
select
  baseModule,
  notification,
  matchedModule,
  matchedModule.getName()  // Name of the similar module