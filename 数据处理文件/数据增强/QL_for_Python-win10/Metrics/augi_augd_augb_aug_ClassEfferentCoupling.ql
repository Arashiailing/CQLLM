/**
 * @name Class External Dependency Analysis
 * @description This analysis computes the count of unique external classes that each class in the codebase
 *              depends on. The metric, known as efferent coupling, measures how many other classes a given
 *              class relies upon. Higher values indicate classes with more dependencies, which typically
 *              results in reduced maintainability, increased complexity, and more challenging testing scenarios.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// Identify classes with external dependencies for coupling analysis
from ClassMetrics targetClass
where exists(targetClass.getEfferentCoupling())
select targetClass, 
       targetClass.getEfferentCoupling() as externalDependencyCount 
order by externalDependencyCount desc