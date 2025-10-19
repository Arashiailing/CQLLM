/**
 * @deprecated
 * @name Mostly duplicate module
 * @description Identifies modules that are exact duplicates of another module. Consolidating duplicate files is recommended to enhance code maintainability and reduce redundancy.
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

// Identify pairs of modules with identical content
from Module sourceModule, Module duplicateModule, string alertMessage
where 
  // Ensure we're not comparing a module to itself
  sourceModule != duplicateModule
  // Verify exact content match between files
  and sourceModule.getFile().getContents() = duplicateModule.getFile().getContents()
  // Enforce consistent ordering to prevent duplicate alerts
  and sourceModule.getFile().getAbsolutePath() < duplicateModule.getFile().getAbsolutePath()
  // Generate descriptive alert message
  and alertMessage = "This file is an exact duplicate of " + duplicateModule.getName()
select sourceModule, alertMessage, duplicateModule, duplicateModule.getName()