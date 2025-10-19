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

// 定义一个模块，用于配置远程流源到达的规则
module RemoteFlowSourceReachConfig implements DataFlow::ConfigSig {
  // 定义一个谓词函数，判断节点是否是源节点
  predicate isSource(DataFlow::Node node) {
    // 节点是远程流源并且不在忽略文件中
    node instanceof RemoteFlowSource and
    not node.getLocation().getFile() instanceof IgnoredFile
  }

  // 定义一个谓词函数，判断节点是否是汇节点
  predicate isSink(DataFlow::Node node) {
    // 节点不在忽略文件中
    not node.getLocation().getFile() instanceof IgnoredFile
    // 我们可以尝试减少这个配置中的汇节点数量，通过只允许在localFlowStep、readStep或storeStep一端的节点，
    // 但是这是一个脆弱的解决方案，需要我们在添加新内容到数据流库时记住更新这个文件。
    //
    // 从几个项目的测试来看，尝试减少节点数量，我们只能减少大约40%的范围，虽然这很好，但对于元查询来说似乎不值得。
  }
}

// 定义一个全局污点跟踪的数据流模块
module RemoteFlowSourceReachFlow = TaintTracking::Global<RemoteFlowSourceReachConfig>;

// 查询语句：选择所有可以从远程流源到达的节点，并显示这些节点的详细信息
from DataFlow::Node reachable
where RemoteFlowSourceReachFlow::flow(_, reachable)
select reachable, prettyNode(reachable)
