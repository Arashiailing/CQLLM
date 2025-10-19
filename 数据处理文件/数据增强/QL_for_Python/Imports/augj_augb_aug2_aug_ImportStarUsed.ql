/**
 * @name Wildcard Import Usage
 * @description Detects Python files using wildcard imports ('from ... import *'), 
 *              which may cause namespace pollution and reduce code clarity.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

import python

// Identify all wildcard import statements in Python code
from ImportStar starImport
// Report each occurrence with maintainability warning
select starImport, "Wildcard import 'from ... import *' pollutes namespace and harms code maintainability."