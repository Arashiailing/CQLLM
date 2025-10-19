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

// Import the Python analysis module to enable static analysis of Python code
import python

// Define the source of wildcard import statements we want to detect
from ImportStar wildcardImport

// Report all instances of wildcard imports with a warning message
// This helps maintain code clarity by avoiding namespace pollution
select wildcardImport, "Using 'from ... import *' pollutes the namespace."