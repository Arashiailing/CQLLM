/**
 * @name Wildcard Import Usage
 * @description Detects Python files containing wildcard imports ('from ... import *'), 
 *              which can lead to namespace pollution and reduced code clarity.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module for examining source code
import python

// Define the source of wildcard imports in Python code
from ImportStar starImport
// Generate an alert for each identified wildcard import statement
select starImport, "Using 'from ... import *' can cause namespace pollution and reduce code maintainability."