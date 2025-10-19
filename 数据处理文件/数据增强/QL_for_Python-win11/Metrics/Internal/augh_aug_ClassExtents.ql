/**
 * @name Extents of classes
 * @description Provides a comprehensive view of all class definitions and their locations throughout the codebase.
 * @kind extent
 * @id py/class-extents
 * @metricType reftype
 */

import python

// Identify all class definitions within the codebase
from Class classEntity
// Extract and return the location and definition of each class
select classEntity.getLocation(), classEntity