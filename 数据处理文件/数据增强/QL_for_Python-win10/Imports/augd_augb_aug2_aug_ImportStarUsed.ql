/**
 * @name Wildcard Import Usage
 * @description Detects Python files using wildcard imports ('from ... import *'), 
 *              which pollutes namespaces and reduces code clarity.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

import python

from ImportStar starImport
select starImport, "Wildcard import ('from ... import *') pollutes namespace and harms code maintainability."