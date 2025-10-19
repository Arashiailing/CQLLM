/**
 * @name Taint sinks
 * @description Sinks from TaintTracking queries.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/taint-sinks
 * @tags meta
 * @precision very-low
 */

// 导入Python库，用于处理Python代码的解析和分析
private import python

// 导入Semmle Python数据流分析库，用于跟踪数据流
private import semmle.python.dataflow.new.DataFlow

// 导入Sinks库，其中定义了各种污点数据接收点（sink）
private import Sinks

// 从字符串类型中选择污点数据接收点，并生成相应的查询结果
from string kind
select taintSink(kind), kind + " sink"
