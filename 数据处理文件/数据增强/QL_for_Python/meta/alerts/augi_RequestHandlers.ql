/**
 * @name Request Handlers
 * @description HTTP Server Request Handlers
 * @kind problem
 * @problem.severity recommendation
 * @id py/meta/alerts/request-handlers
 * @tags meta
 * @precision very-low
 */

// 导入Python代码解析和分析库
private import python

// 导入数据流分析库，用于程序内数据流动跟踪
private import semmle.python.dataflow.new.DataFlow

// 导入Python常用编程概念库
private import semmle.python.Concepts

// 导入元数据指标计算和报告库
private import meta.MetaMetrics

// 定义HTTP服务器请求处理器和标题字符串的查询源
from Http::Server::RequestHandler handler, string handlerTitle
where
  // 排除位于被忽略文件中的处理器
  not handler.getLocation().getFile() instanceof IgnoredFile and
  // 根据处理器类型设置标题
  (if handler.isMethod()
   then
     // 对于方法类型的处理器，标题为"Method 类名.方法名"
     handlerTitle = "Method " + handler.getScope().(Class).getName() + "." + handler.getName()
   else 
     // 对于非方法类型的处理器，标题为其字符串表示
     handlerTitle = handler.toString())
// 输出处理器对象和带有前缀的标题
select handler, "RequestHandler: " + handlerTitle