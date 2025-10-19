/**
 * @name Wildcard import usage detected
 * @description Identifies wildcard imports that may cause namespace pollution
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

import python

from 
  ImportStar starImport
select 
  starImport, 
  "Using 'from ... import *' pollutes the namespace."