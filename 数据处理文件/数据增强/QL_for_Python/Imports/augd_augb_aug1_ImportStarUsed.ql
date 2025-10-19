/**
 * @name 'import *' used
 * @description Detects usage of wildcard imports which can lead to namespace pollution
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

import python

from ImportStar wildcardImport
select wildcardImport, "Using 'from ... import *' pollutes the namespace."