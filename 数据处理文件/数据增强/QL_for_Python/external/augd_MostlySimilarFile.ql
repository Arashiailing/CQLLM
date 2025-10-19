/**
 * @deprecated
 * @name Mostly similar module
 * @description Detects modules with significant code overlap. Variable names and types may differ between modules. Consolidating these modules improves maintainability.
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

// Define variables for module comparison and alert message
from Module sourceModule, Module targetModule, string alertMessage
where 
  // No filtering condition applied (matches original none())
  none()
select 
  sourceModule, 
  alertMessage, 
  targetModule, 
  targetModule.getName()