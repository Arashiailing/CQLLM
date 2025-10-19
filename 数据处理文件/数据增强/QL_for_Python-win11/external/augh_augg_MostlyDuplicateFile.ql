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

// Locate pairs of modules with identical content
from Module originalFile, Module duplicateFile, string warningText
where 
  // Ensure we don't compare a file against itself
  originalFile != duplicateFile and
  // Verify that file contents are exactly the same
  originalFile.getFile().getContents() = duplicateFile.getFile().getContents() and
  // Enforce consistent ordering to prevent duplicate alerts
  originalFile.getFile().getAbsolutePath() < duplicateFile.getFile().getAbsolutePath() and
  // Create descriptive warning message
  warningText = "This file is an exact duplicate of " + duplicateFile.getName()
select originalFile, warningText, duplicateFile, duplicateFile.getName()