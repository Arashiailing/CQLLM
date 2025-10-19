/**
 * @name Resolvable calls by points-to, to relevant callee
 * @description 计算可以通过指向分析解析到相关被调用者的（相关）调用数量。
 * @kind metric
 * @metricType project
 * @metricAggregate sum
 * @tags meta
 * @id py/meta/points-to-resolvable-calls-relevant-callee
 */

import python // 导入Python库，用于处理Python代码的分析
import CallGraphQuality // 导入CallGraphQuality库，用于调用图质量相关的分析

// 选择项目根节点和通过指向分析可以解析到相关目标的可解析调用的数量
select projectRoot(), count(PointsToBasedCallGraph::ResolvableCallRelevantTarget call)
