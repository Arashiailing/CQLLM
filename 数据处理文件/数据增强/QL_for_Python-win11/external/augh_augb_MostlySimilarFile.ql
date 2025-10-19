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
  Module sourceModule,      // Original module being analyzed
  Module similarModule,     // Module exhibiting high similarity
  string description        // Descriptive alert message
where
  // Assign descriptive message while maintaining no filtering logic
  description = "Modules exhibit substantial code similarity"
select
  sourceModule,
  description,
  similarModule,
  similarModule.getName()  // Name of the similar module