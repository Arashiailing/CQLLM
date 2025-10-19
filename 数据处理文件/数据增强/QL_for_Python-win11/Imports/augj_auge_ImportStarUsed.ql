/**
 * @name 'import *' used
 * @description Detects usage of 'import *' statements in Python code, which can lead to namespace pollution and hinder code analysis.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import Python analysis module
import python

// Identify all wildcard import statements
from ImportStar wildcardImport

// Report namespace pollution issues
select wildcardImport, 
       "Wildcard imports ('from ... import *') pollute the global namespace and reduce code clarity."