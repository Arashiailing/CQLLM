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

// Import the Python analysis library to enable code pattern detection
import python

// This query identifies all wildcard import statements (using 'import *' syntax)
// in the codebase. Wildcard imports can cause namespace pollution by importing
// all names from a module into the current namespace, potentially causing
// name conflicts and making code harder to understand and maintain.
from ImportStar wildcardImport

// Report each detected wildcard import with a warning message explaining
// the potential issues with namespace pollution
select wildcardImport, "Using 'from ... import *' pollutes the namespace."