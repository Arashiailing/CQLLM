/**
 * @name Wildcard Import Usage
 * @description Identifies Python source files that utilize wildcard imports ('from ... import *').
 *              This pattern can introduce namespace pollution and diminish code readability,
 *              making it harder to trace the origin of imported names and potentially causing
 *              unintended name conflicts.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module to enable examination of Python source code constructs
import python

// Define the source of our analysis: all wildcard import statements in Python code
from ImportStar wildcardImport

// Select each wildcard import statement and provide an explanatory message
// highlighting the maintainability concerns associated with this import pattern
select wildcardImport, 
       "Wildcard import 'from ... import *' may cause namespace pollution and reduce code maintainability."