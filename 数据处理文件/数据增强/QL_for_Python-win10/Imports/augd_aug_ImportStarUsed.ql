/**
 * @name 'import *' used
 * @description Detects Python files utilizing wildcard imports ('from ... import *').
 *              Such imports may cause namespace pollution and naming collisions,
 *              potentially compromising code maintainability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

import python

from ImportStar starImportStmt
select starImportStmt, "Wildcard import ('from ... import *') pollutes global namespace and reduces code clarity."