/**
 * @name 'import *' used
 * @description Detects usage of 'import *' statements in Python code, which can lead to namespace pollution and hinder code analysis.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python module for code analysis
import python

// Find all instances of 'import *' statements
from ImportStar importStarStmt

// Report each instance with a warning about namespace pollution
select importStarStmt, 
       "Using 'from ... import *' pollutes the namespace."