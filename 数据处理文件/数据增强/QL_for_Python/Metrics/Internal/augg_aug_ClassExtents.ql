/**
 * @name Extents of classes
 * @description Enumerates all class definitions in the Python codebase, providing their
 *              exact source locations for comprehensive code analysis and navigation.
 * @kind extent
 * @id py/class-extents
 * @metricType reftype
 */

import python

// Retrieve every class definition within the codebase
from Class cls
// Report the source location and the class entity for comprehensive analysis
select cls.getLocation(), cls