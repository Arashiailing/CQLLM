/**
 * @name Summarized callable call sites
 * @description A call site for which we have a summarized callable
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// 导入Python语言核心库
import python
// 导入数据流分析相关模块
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// 导入元度量分析模块
import meta.MetaMetrics

// 定义分析变量：调用位置、目标摘要函数、调用类型
from DataFlow::Node callSite, SummarizedCallable summarizedCallable, string invocationKind
where
  // 直接调用场景：调用位置匹配目标函数的调用点
  (callSite = summarizedCallable.getACall() and invocationKind = "Call")
  or
  // 回调调用场景：调用位置匹配目标函数的回调点
  (callSite = summarizedCallable.getACallback() and invocationKind = "Callback")
  and
  // 排除忽略文件中的调用位置
  not callSite.getLocation().getFile() instanceof IgnoredFile
// 输出调用位置和格式化调用类型与目标函数信息
select callSite, invocationKind + " to " + summarizedCallable