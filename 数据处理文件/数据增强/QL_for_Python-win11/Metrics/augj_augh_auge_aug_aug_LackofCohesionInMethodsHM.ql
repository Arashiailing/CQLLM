/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Quantifies the cohesion deficiency in Python classes using
 *              the Hitz and Montazeri (HM) method. Elevated values signify
 *              diminished class cohesion, indicating potential design issues.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Core Python analysis module for class metrics evaluation

// Identify classes with calculable HM cohesion deficiency
// and extract their deficiency metric value
from ClassMetrics classMetric, float cohesionDeficiencyValue
where 
    // Ensure HM metric exists for the class
    exists(classMetric.getLackOfCohesionHM()) and
    // Assign the calculated deficiency value
    cohesionDeficiencyValue = classMetric.getLackOfCohesionHM()

// Output results ordered by descending cohesion deficiency severity
select 
    classMetric, 
    cohesionDeficiencyValue as cohesionDeficiency 
order by 
    cohesionDeficiency desc