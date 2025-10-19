/**
 * @name Wildcard import usage detected
 * @description Identifies instances of wildcard imports that may cause namespace pollution
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import Python analysis module for code pattern identification
import python

// Find all wildcard import statements in the project
from ImportStar wildcardImport

// Generate alerts for each wildcard import found, highlighting namespace pollution risk
select wildcardImport, "Wildcard imports ('from ... import *') can lead to namespace pollution."