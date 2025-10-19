/**
 * @name 调用具有摘要的函数的调用点
 * @description 查找那些调用了具有摘要的函数的调用点
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// 导入Python语言核心模块
import python
// 导入数据流分析相关模块
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// 导入元度量分析模块
import meta.MetaMetrics

// 定义分析变量：调用节点、目标摘要函数、调用类型
from DataFlow::Node callNode, SummarizedCallable summarizedFunc, string callType
where
  // 排除忽略文件中的调用节点
  not callNode.getLocation().getFile() instanceof IgnoredFile
  and
  (
    // 直接调用场景：调用节点匹配目标函数的调用点
    (callNode = summarizedFunc.getACall() and callType = "Call")
    or
    // 回调调用场景：调用节点匹配目标函数的回调点
    (callNode = summarizedFunc.getACallback() and callType = "Callback")
  )
// 输出调用节点和格式化调用类型与目标函数信息
select callNode, callType + " to " + summarizedFunc