/**
 * @deprecated
 * @name Mostly duplicate module
 * @description Detects files that are exact duplicates of another file. Consider merging duplicate files to improve maintainability.
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

// Identify Python modules that are exact duplicates by comparing file contents
from Module originalModule, Module duplicateModule, string warningMessage
where 
  // Ensure we're comparing two different modules
  originalModule != duplicateModule and
  // Check if the file contents are identical
  originalModule.getFile().getContents() = duplicateModule.getFile().getContents() and
  // Enforce consistent ordering to avoid duplicate reports by comparing absolute paths
  originalModule.getFile().getAbsolutePath() < duplicateModule.getFile().getAbsolutePath() and
  // Generate a descriptive warning message about the duplicate file
  warningMessage = "This file is an exact duplicate of " + duplicateModule.getName()
select originalModule, warningMessage, duplicateModule, duplicateModule.getName()