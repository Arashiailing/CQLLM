/**
 * @name Display strings of classes
 * @description Identifies all Python classes in the codebase and presents their names as display strings.
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Define source for all Python classes in the codebase
from Class cls

// Output class object with its name as display string
select cls, cls.getName()