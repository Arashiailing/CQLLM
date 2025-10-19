/**
 * @name Summarized callable call sites
 * @description A call site for which we have a summarized callable
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/summarized-callable-call-sites
 * @tags meta
 * @precision very-low
 */

// 导入Python语言库
import python
// 导入数据流分析相关的模块
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.FlowSummary
// 导入元度量模块
import meta.MetaMetrics

// 从DataFlow::Node中引入useSite, SummarizedCallable target, string kind
from DataFlow::Node useSite, SummarizedCallable target, string kind
where
  // 条件1：useSite是target的一个调用，并且kind为"Call"
  (
    useSite = target.getACall() and kind = "Call"
    // 条件2：useSite是target的一个回调，并且kind为"Callback"
    or
    useSite = target.getACallback() and kind = "Callback"
  ) and
  // 排除忽略文件中的调用位置
  not useSite.getLocation().getFile() instanceof IgnoredFile
// 选择useSite和kind + " to " + target作为结果输出
select useSite, kind + " to " + target
