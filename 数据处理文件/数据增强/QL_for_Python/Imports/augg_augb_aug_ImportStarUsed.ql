/**
 * @name 'import *' used
 * @description Detects Python files utilizing wildcard imports ('from ... import *'), which may cause namespace pollution and reduce code maintainability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import Python analysis module for source code examination
import python

// Identify all wildcard import statements in the codebase
from ImportStar wildcardImport
// Generate alert for each detected wildcard import
select wildcardImport, "Using 'from ... import *' pollutes the namespace."