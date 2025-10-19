/**
 * @name Resolvable call candidates
 * @description The number of (relevant) calls in the program.
 * @kind metric
 * @metricType project
 * @metricAggregate sum
 * @tags meta
 * @id py/meta/resolvable-call-candidates
 */

import python  // 导入python库，用于分析Python代码
import CallGraphQuality  // 导入CallGraphQuality库，用于调用图质量分析

// 选择项目根目录和相关调用的数量
select projectRoot(), count(RelevantCall call)
