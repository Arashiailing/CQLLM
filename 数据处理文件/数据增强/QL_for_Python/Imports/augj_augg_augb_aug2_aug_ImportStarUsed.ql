/**
 * @name Wildcard Import Usage
 * @description Identifies Python files that utilize wildcard imports ('from ... import *'),
 *              which can cause namespace pollution and decrease code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import required Python analysis modules for code inspection
import python

// Find all wildcard import statements in the analyzed codebase
from ImportStar wildcardImport

// Generate alerts for each detected wildcard import with an informative message
select wildcardImport, "Utilization of 'from ... import *' can lead to namespace pollution and adversely affect code maintainability."