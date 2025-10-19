/**
 * @name 'import *' used
 * @description Detects usage of wildcard imports which can lead to namespace pollution and hinder code analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used */

// Import the Python analysis library to enable detection of Python code patterns
import python

// Identify all instances where wildcard imports are used in the codebase
// These imports can introduce multiple names into the namespace, potentially causing naming conflicts
from ImportStar starImport

// Report each wildcard import found with a message explaining the namespace pollution issue
select starImport, "Using 'from ... import *' pollutes the namespace and may lead to naming conflicts."