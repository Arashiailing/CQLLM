/**
 * @name Class Efferent Coupling Analysis
 * @description Measures the count of external classes that a given class relies on.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 分析每个类的外部依赖数量
from ClassMetrics analyzedClass
select analyzedClass, 
       analyzedClass.getEfferentCoupling() as dependencyCount 
order by dependencyCount desc