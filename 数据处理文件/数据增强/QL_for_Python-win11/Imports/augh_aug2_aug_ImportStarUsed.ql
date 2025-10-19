/**
 * @name Wildcard Import Detection
 * @description Identifies Python files that use wildcard imports ('from ... import *'), which can cause namespace pollution and reduce code maintainability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the necessary Python analysis module for code inspection
import python

// Source of wildcard imports in Python code
from ImportStar wildcardImport
// Generate an alert for each instance of wildcard import usage
select wildcardImport, "Using 'from ... import *' pollutes the namespace."