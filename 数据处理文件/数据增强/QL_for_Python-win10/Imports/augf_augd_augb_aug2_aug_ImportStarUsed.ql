/**
 * @name Wildcard Import Detection
 * @description Identifies Python source files that utilize wildcard imports ('from ... import *').
 *              This practice can lead to namespace pollution and decreased code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

import python

// Define a variable to capture wildcard import instances
from ImportStar wildcardImport

// Select all wildcard imports with a descriptive message
select wildcardImport, "Wildcard import ('from ... import *') pollutes namespace and harms code maintainability."