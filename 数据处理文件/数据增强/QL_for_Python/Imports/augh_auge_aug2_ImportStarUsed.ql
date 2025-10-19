/**
 * @name Wildcard import usage detected
 * @description Identifies wildcard imports that cause namespace pollution and reduce code clarity
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Enable Python code analysis capabilities through the Python module
import python

// Locate all wildcard import statements in the codebase
// These imports introduce all names from a module into the current namespace
from ImportStar starImport
// Report detected wildcard imports with explanatory warning
// The warning highlights namespace pollution risks and maintainability concerns
select starImport, "Wildcard import 'from ... import *' pollutes namespace and reduces code clarity"