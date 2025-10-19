/**
 * @name Wildcard Import Usage
 * @description Identifies Python source files that employ wildcard imports ('from ... import *'), 
 *              which can cause namespace pollution and reduce code clarity.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module for source code examination
import python

// Define the source of wildcard imports in Python code
from ImportStar wildcardImportStmt
// Generate an alert for each identified wildcard import statement
select wildcardImportStmt, "Utilizing 'from ... import *' introduces namespace pollution and may decrease code maintainability."