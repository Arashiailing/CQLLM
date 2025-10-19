/**
 * @name Ratio of resolvable call by points-to
 * @description The percentage of (relevant) calls that can be resolved to a callee.
 * @kind metric
 * @metricType project
 * @metricAggregate sum min max avg
 * @tags meta
 * @id py/meta/points-to-resolvable-call-ratio
 */

// 导入Python库，用于处理Python代码的查询
import python

// 导入CallGraphQuality库，用于分析调用图的质量
import CallGraphQuality

// 选择项目根节点和计算可解析调用的比例
select projectRoot(),
  // 计算可解析调用的数量占相关调用总数的百分比
  100.0 * count(PointsToBasedCallGraph::ResolvableCall call) / count(RelevantCall call).(float)
