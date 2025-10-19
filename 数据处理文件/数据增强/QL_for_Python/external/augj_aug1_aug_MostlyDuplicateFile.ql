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
  Module sourceModule, 
  Module duplicateModule
where 
  /* Ensure we're comparing distinct modules */
  sourceModule != duplicateModule and
  /* Extract file contents for comparison */
  exists(
    string sourceContent, 
    string duplicateContent |
    sourceContent = sourceModule.getLocation().getFile().getContents() and
    duplicateContent = duplicateModule.getLocation().getFile().getContents() and
    sourceContent = duplicateContent
  ) and
  /* Prevent duplicate reporting via path ordering */
  sourceModule.getLocation().getFile().getAbsolutePath() < 
  duplicateModule.getLocation().getFile().getAbsolutePath()
select 
  sourceModule, 
  "This file is a duplicate of " + duplicateModule.getName(), 
  duplicateModule, 
  duplicateModule.getName()