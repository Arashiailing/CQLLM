/**
 * @name Remote flow sources
 * @description Sources of remote user input.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/remote-flow-sources
 * @tags meta
 * @precision very-low
 */

// 导入Python库，用于处理Python代码的解析和分析
private import python

// 导入数据流分析相关的库，用于追踪数据流
private import semmle.python.dataflow.new.DataFlow

// 导入远程数据流源分析库，用于识别远程用户输入的数据流源
private import semmle.python.dataflow.new.RemoteFlowSources

// 导入元度量库，用于收集和报告元数据
private import meta.MetaMetrics

// 从RemoteFlowSource类中选择所有实例作为数据源
from RemoteFlowSource source

// 过滤条件：排除在IgnoredFile中的文件
where not source.getLocation().getFile() instanceof IgnoredFile

// 选择符合条件的数据源，并生成带有源类型描述的报告项
select source, "RemoteFlowSource: " + source.getSourceType()
