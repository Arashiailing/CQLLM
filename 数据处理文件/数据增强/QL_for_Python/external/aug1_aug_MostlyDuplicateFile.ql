/**
 * @deprecated
 * @name Mostly duplicate file detector
 * @description Identifies Python files with near-identical code content. Such duplicates increase maintenance burden and should be consolidated.
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

from 
  Module originalFile, 
  Module duplicateFile, 
  string description
where 
  /* Ensure we're comparing distinct files */
  originalFile != duplicateFile and
  /* Compare file contents for exact duplication */
  originalFile.getLocation().getFile().getContents() = duplicateFile.getLocation().getFile().getContents() and
  /* Prevent duplicate reporting by enforcing path ordering */
  originalFile.getLocation().getFile().getAbsolutePath() < duplicateFile.getLocation().getFile().getAbsolutePath() and
  /* Generate descriptive alert message */
  description = "This file is a duplicate of " + duplicateFile.getName()
select 
  originalFile, 
  description, 
  duplicateFile, 
  duplicateFile.getName()