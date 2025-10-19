/**
 * @name 'import *' used
 * @description Identifies Python files that use wildcard imports ('from ... import *'), which can introduce naming conflicts and reduce code clarity.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module to enable examination of Python source code
import python

// Identify all wildcard import statements in the codebase
from ImportStar wildcardImport
// Generate an alert for each wildcard import found
select wildcardImport, "Using 'from ... import *' pollutes the namespace."