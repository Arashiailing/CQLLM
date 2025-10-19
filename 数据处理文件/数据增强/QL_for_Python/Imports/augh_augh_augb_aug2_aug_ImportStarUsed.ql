/**
 * @name Wildcard Import Usage
 * @description Identifies Python files utilizing wildcard imports ('from ... import *')
 *              which can cause namespace pollution and reduce code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis framework to enable code examination
import python

// Find all wildcard import statements throughout the codebase
from ImportStar wildcardImport
// Generate a report for each identified wildcard import with an explanatory message
select wildcardImport, "Wildcard imports ('from ... import *') can pollute the namespace and reduce code clarity, making maintenance more difficult."