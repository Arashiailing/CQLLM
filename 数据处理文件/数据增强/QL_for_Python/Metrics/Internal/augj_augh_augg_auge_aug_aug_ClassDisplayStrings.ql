/**
 * @name Python Class Display Strings
 * @description Identifies and lists all Python classes in the codebase,
 *              presenting their names as formatted strings for reference.
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

from Class classDefinition // All Python class definitions in the codebase

select classDefinition, classDefinition.getName() // Class entity with its name