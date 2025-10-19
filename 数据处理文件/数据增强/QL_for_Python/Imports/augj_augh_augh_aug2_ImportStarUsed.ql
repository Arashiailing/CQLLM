/**
 * @name 'import *' used
 * @description Using import * prevents some analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import Python language analysis module for static code examination
import python

// Identify all wildcard import statements in the codebase
// These imports bring all symbols from a module into the current namespace
// which can lead to namespace pollution and reduced code clarity
from ImportStar wildcardImport

// Generate results for each wildcard import found
// with a message explaining the potential maintainability issues
select wildcardImport, "Using 'from ... import *' pollutes the namespace."