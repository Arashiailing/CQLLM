/**
 * @name Wildcard import usage detected
 * @description Detects the use of wildcard imports which can lead to namespace pollution
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module to enable static analysis capabilities for Python code
import python

// Identify all instances where wildcard imports are used in the codebase
// Wildcard imports (import *) can cause namespace pollution and make code harder to understand
from ImportStar wildcardImport
// Output the identified wildcard import statements along with a warning message
// The message explains that wildcard imports pollute the namespace and should be avoided
select wildcardImport, "Using 'from ... import *' pollutes the namespace."