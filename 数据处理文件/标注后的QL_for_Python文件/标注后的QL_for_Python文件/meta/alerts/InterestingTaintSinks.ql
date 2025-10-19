/**
 * @name Interesting taint sinks
 * @description Interesting sinks from TaintTracking queries.
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/interesting-taint-sinks
 * @tags meta
 * @precision very-low
 */

// 导入Python库
private import python

// 导入Semmle Python数据流分析库
private import semmle.python.dataflow.new.DataFlow

// 导入Sinks库，用于识别潜在的敏感信息泄露点
private import Sinks

// 从string类型中选择种类（kind）
from string kind

// 过滤掉"CleartextLogging"和"LogInjection"类型的sink
where not kind in ["CleartextLogging", "LogInjection"]

// 选择并返回符合条件的taintSink及其对应的种类名称
select taintSink(kind), kind + " sink"
