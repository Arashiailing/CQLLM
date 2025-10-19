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

// Identify duplicate modules by comparing file contents
from Module sourceModule, Module targetModule, string alertMessage
where 
  // Ensure we're not comparing a module to itself
  sourceModule != targetModule and
  // Compare file contents for exact duplication
  sourceModule.getFile().getContents() = targetModule.getFile().getContents() and
  // Prevent duplicate reporting by enforcing consistent ordering
  sourceModule.getFile().getAbsolutePath() < targetModule.getFile().getAbsolutePath() and
  // Generate descriptive alert message
  alertMessage = "This file is an exact duplicate of " + targetModule.getName()
select sourceModule, alertMessage, targetModule, targetModule.getName()