/**
 * @name 'import *' used
 * @description Detects wildcard imports that can pollute the namespace and impede code analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module for parsing and analyzing Python code
import python

// Identify all statements that utilize wildcard imports
from ImportStar wildcardImport

// Report findings: flag each wildcard import with a descriptive warning message
select wildcardImport, "Wildcard import 'from ... import *' introduces all names into the current namespace, potentially causing name conflicts and making code analysis more difficult."