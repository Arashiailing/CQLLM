/**
 * @name Wildcard import usage detected
 * @description Importing all names using '*' can cause namespace pollution and hinder static analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import Python analysis library for code inspection capabilities
import python

// Identify all statements using wildcard import syntax (import *)
// This practice brings all public members from a module into the current namespace
from ImportStar starImport

// Report findings: flag each wildcard import statement with a warning
// Alert message explains the namespace pollution risk associated with this import style
select starImport, "Using 'from ... import *' pollutes the namespace."