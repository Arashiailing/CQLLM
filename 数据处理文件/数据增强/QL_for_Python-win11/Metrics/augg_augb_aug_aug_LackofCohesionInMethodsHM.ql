/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Quantifies class cohesion deficiency employing Hitz and Montazeri's approach.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// Detect classes exhibiting poor cohesion using the HM assessment technique
// This evaluation examines the connectivity between methods and instance attributes
from ClassMetrics clsMetric

// Arrange output to prioritize classes with the most critical cohesion deficiencies
// Fetch class data and compute its cohesion deficiency metric
// Elevated scores signify more pronounced cohesion problems within the class
select 
    clsMetric, 
    clsMetric.getLackOfCohesionHM() as cohesionValue 
order by 
    cohesionValue desc