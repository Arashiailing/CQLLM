/**
 * @name Resolvable calls by points-to
 * @description The number of (relevant) calls that can be resolved to a callee.
 * @kind metric
 * @metricType project
 * @metricAggregate sum
 * @tags meta
 * @id py/meta/points-to-resolvable-calls
 */

// 导入Python库，用于处理Python代码的CodeQL查询
import python

// 导入CallGraphQuality库，用于调用图质量分析
import CallGraphQuality

// 选择项目根目录，并计算通过指向关系可以解析的调用数量
select projectRoot(), count(PointsToBasedCallGraph::ResolvableCall call)
