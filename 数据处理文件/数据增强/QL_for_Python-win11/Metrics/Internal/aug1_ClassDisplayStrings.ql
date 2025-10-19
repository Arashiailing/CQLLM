/**
 * @name Show string representations of Python classes
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Query all Python classes in the codebase
from Class pythonClass
// Select the class object and its name as the display string
select pythonClass, pythonClass.getName()