/**
 * @name Display strings of classes
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 * @description Identifies and displays all Python classes along with their names.
 *              This query helps in understanding the class structure of a Python codebase.
 */

import python

// Define the source of our analysis: all Python classes
from Class classDefinition

// Extract and present the class information
select classDefinition, classDefinition.getName() // The class object and its name are returned for display