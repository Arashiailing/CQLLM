/**
 * @deprecated
 * @name Out-of-bounds Read
 * @kind problem
 * @id py/out-of-bounds-read
 * @problem.severity error
 * @precision high
 * @metricType problemMetric
 * @metricAggregate overFiles
 */

import python
import semmle.python.pointsto.PointsTo

from ClassValue classVal, Local variable
where
  // 筛选符合条件的类实例：必须是整数类型或缓冲区类型
  (
    // 条件1：类是int类型
    classVal instanceof IntegerClass
    or
    // 条件2：类是buffer类型
    classVal instanceof BufferClass
  )
  and
  // 验证变量是否指向此类实例
  variable.pointsTo(classVal)
select variable, "$@ points to an instance of " + classVal.getName() + ".", variable.asExpr()