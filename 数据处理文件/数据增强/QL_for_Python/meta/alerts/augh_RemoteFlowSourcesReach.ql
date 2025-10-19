/**
 * @name Remote flow sources reach
 * @description Nodes that can be reached with taint tracking from sources of
 *   remote user input.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources-reach
 * @tags meta
 * @precision very-low
 */

// 导入Python库
private import python
// 导入数据流分析相关的库
private import semmle.python.dataflow.new.DataFlow
// 导入污点跟踪相关的库
private import semmle.python.dataflow.new.TaintTracking
// 导入远程流源相关的库
private import semmle.python.dataflow.new.RemoteFlowSources
// 导入元度量相关的库
private import meta.MetaMetrics
// 导入内部打印节点相关的库
private import semmle.python.dataflow.new.internal.PrintNode

// 配置远程流源到达分析规则的模块
module RemoteFlowSourceReachAnalysis implements DataFlow::ConfigSig {
  /**
   * 判断节点是否为有效源节点
   * 要求节点是远程流源且不在忽略文件中
   */
  predicate isSource(DataFlow::Node sourceNode) {
    sourceNode instanceof RemoteFlowSource and
    not sourceNode.getLocation().getFile() instanceof IgnoredFile
  }

  /**
   * 判断节点是否为有效汇节点
   * 仅要求节点不在忽略文件中
   * 
   * 注意：虽然可以尝试通过限制汇节点类型（如仅允许localFlowStep、readStep或storeStep）
   * 来减少分析范围，但测试表明这只能减少约40%的范围，且维护成本较高，
   * 因此当前实现采用更通用的汇节点定义
   */
  predicate isSink(DataFlow::Node sinkNode) {
    not sinkNode.getLocation().getFile() instanceof IgnoredFile
  }
}

// 定义全局污点跟踪分析模块
module RemoteFlowSourceReachTaintFlow = TaintTracking::Global<RemoteFlowSourceReachAnalysis>;

// 主查询：查找所有可被远程流源污染的节点
from DataFlow::Node taintedNode
where RemoteFlowSourceReachTaintFlow::flow(_, taintedNode)
select taintedNode, prettyNode(taintedNode)