/**
 * @name Display strings of classes
 * @description This query identifies all Python classes within the codebase and presents their names as display strings for easy reference and analysis.
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Source definition: Retrieve all Python classes present in the analyzed codebase
from Class pythonClass

// Result presentation: Output each class object along with its name as a display string
select pythonClass, pythonClass.getName()