/**
 * @deprecated
 * @name Mostly duplicate module
 * @description Detects modules that are exact content duplicates of another module. Consolidating such files improves maintainability and reduces code redundancy.
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
 * @id py/mostly-duplicate-file
 */

import python

// Identify pairs of distinct modules with identical content
from Module sourceModule, Module duplicateModule, string alertMessage
where 
  // Exclude self-comparisons
  sourceModule != duplicateModule and
  // Verify exact content match between files
  sourceModule.getFile().getContents() = duplicateModule.getFile().getContents() and
  // Enforce consistent ordering to prevent duplicate alerts
  sourceModule.getFile().getAbsolutePath() < duplicateModule.getFile().getAbsolutePath() and
  // Generate descriptive alert message
  alertMessage = "This file is an exact duplicate of " + duplicateModule.getName()
select sourceModule, alertMessage, duplicateModule, duplicateModule.getName()