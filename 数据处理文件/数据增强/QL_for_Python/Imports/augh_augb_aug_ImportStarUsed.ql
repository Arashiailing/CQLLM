/**
 * @name Wildcard Import Usage Detected
 * @description Identifies Python code that employs wildcard imports (using 'from ... import *' syntax), which can lead to namespace pollution and decreased code clarity.
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

// Main query logic:
// 1. Find all wildcard imports in the code
// 2. Report each one with a warning message
from ImportStar wildcardImport
select wildcardImport, "Using 'from ... import *' pollutes the namespace."