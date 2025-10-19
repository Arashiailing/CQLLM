/**
 * @name 'import *' used
 * @description Using import * prevents some analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module to enable parsing and analysis of Python source code
import python

// Identify all instances of wildcard imports (import *) in the codebase
from ImportStar wildcardImport

// Report each wildcard import with a warning message about namespace pollution and analysis hindrance
select wildcardImport, "Using 'from ... import *' pollutes the namespace and may hinder code analysis."