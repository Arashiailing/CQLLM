/**
 * @name Wildcard Import Usage
 * @description Detects Python files using wildcard imports ('from ... import *'), 
 *              which may lead to namespace pollution and reduced code clarity.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import Python analysis module for code examination
import python

// Identify wildcard import statements in Python source files
from ImportStar starImport
// Report each wildcard import with maintainability concern
select starImport, "Wildcard imports ('from ... import *') can cause namespace pollution and reduce code maintainability."