/**
 * @deprecated
 * @name Mostly duplicate module
 * @description Detects modules that are exact duplicates of another module. Consolidating duplicate files is recommended to enhance code maintainability and reduce redundancy.
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

// Find modules with identical content
from Module originalModule, Module replicaModule, string alertText
where 
  // Ensure distinct modules to avoid self-comparison
  originalModule != replicaModule
  // Verify exact content match between files
  and originalModule.getFile().getContents() = replicaModule.getFile().getContents()
  // Enforce path ordering to prevent duplicate alerts
  and originalModule.getFile().getAbsolutePath() < replicaModule.getFile().getAbsolutePath()
  // Construct descriptive alert message
  and alertText = "This file is an exact duplicate of " + replicaModule.getName()
select originalModule, alertText, replicaModule, replicaModule.getName()