/**
 * @name 'import *' used
 * @description Identifies wildcard imports that may cause namespace pollution
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Enable Python code analysis capabilities
import python

// Define pattern for wildcard import statements
from ImportStar starImport

// Report findings with contextual warning message
select starImport, "Using 'from ... import *' pollutes the namespace."