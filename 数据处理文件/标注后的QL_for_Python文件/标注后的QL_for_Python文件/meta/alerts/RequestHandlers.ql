/**
 * @name Request Handlers
 * @description HTTP Server Request Handlers
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// 导入Python库，用于处理Python代码的解析和分析
private import python

// 导入数据流分析库，用于跟踪数据在程序中的流动
private import semmle.python.dataflow.new.DataFlow

// 导入Python概念库，包含一些常用的Python编程概念
private import semmle.python.Concepts

// 导入MetaMetrics库，用于计算和报告元数据指标
private import meta.MetaMetrics

// 从Http::Server::RequestHandler类中选择requestHandler对象和title字符串
from Http::Server::RequestHandler requestHandler, string title
where
  // 过滤掉被忽略的文件
  not requestHandler.getLocation().getFile() instanceof IgnoredFile and
  // 如果requestHandler是一个方法
  if requestHandler.isMethod()
  then
    // 设置title为"Method " + 类名 + "." + 方法名
    title = "Method " + requestHandler.getScope().(Class).getName() + "." + requestHandler.getName()
  else 
    // 否则，将title设置为requestHandler的字符串表示形式
    title = requestHandler.toString()
// 选择requestHandler对象和带有前缀"RequestHandler: "的title字符串
select requestHandler, "RequestHandler: " + title
