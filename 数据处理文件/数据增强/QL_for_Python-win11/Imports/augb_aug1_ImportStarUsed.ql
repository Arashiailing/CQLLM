/**
 * @name 'import *' used
 * @description Detects usage of wildcard imports which can lead to namespace pollution
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis library to enable code pattern detection
import python

// Identify all instances where wildcard imports are used in the codebase
from ImportStar starImport

// Report each wildcard import instance with a warning about namespace pollution
select starImport, "Using 'from ... import *' pollutes the namespace."