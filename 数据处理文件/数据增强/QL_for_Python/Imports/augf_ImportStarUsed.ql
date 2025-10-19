/**
 * @name 'import *' used
 * @description Identifies usage of wildcard imports which can hinder code analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import Python analysis module for code inspection
import python

// Select all instances of wildcard imports (from ... import *)
from ImportStar starImport
// Generate alert for each wildcard import found, explaining namespace pollution issue
select starImport, "Using 'from ... import *' pollutes the namespace."