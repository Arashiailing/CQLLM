/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Evaluates class cohesion deficiency using Hitz and Montazeri's methodology.
 *              This metric quantifies how dispersed instance variables are across methods,
 *              where higher scores indicate poorer class cohesion.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// This query implements the Hitz and Montazeri (HM) method to assess class cohesion
// The HM approach analyzes the connectivity between instance variables and methods
// A higher deficiency score suggests that class responsibilities are too dispersed

// Retrieve class metrics and compute the HM cohesion deficiency score
// The score reflects how scattered the class's internal structure is
from ClassMetrics clsMetrics
select 
    clsMetrics, 
    clsMetrics.getLackOfCohesionHM() as cohesionScore 

// Order results by highest deficiency scores first
// Classes with poor cohesion should be prioritized for refactoring
order by 
    cohesionScore desc