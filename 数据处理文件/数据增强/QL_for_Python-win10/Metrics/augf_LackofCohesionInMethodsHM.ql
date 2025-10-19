/**
 * @name Lack of Cohesion in a Class (Hitz-Montazeri Metric)
 * @description Measures class cohesion deficiency using Hitz and Montazeri's methodology.
 *              Higher values indicate weaker internal cohesion within the class.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Core module for Python code analysis

// Extract class metrics and compute cohesion deficiency
from ClassMetrics classMetric
where exists(classMetric.getLackOfCohesionHM())  // Ensure metric exists
select 
  classMetric, 
  classMetric.getLackOfCohesionHM() as cohesionDeficiency 
order by 
  cohesionDeficiency desc  // Prioritize classes with highest cohesion issues