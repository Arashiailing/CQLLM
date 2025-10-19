/**
 * @name Wildcard Import Usage
 * @description Detects Python files utilizing wildcard imports ('from ... import *'), which may lead to namespace pollution and decreased code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module for source code examination
import python

// Define the source of wildcard imports
from ImportStar starImport
// Create an alert for each detected wildcard import
select starImport, "Using 'from ... import *' pollutes the namespace."