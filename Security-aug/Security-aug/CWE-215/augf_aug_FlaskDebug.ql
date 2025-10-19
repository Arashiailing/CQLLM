/**
 * @name Flask 应用在调试模式下运行
 * @description 当 Flask 应用程序在调试模式下运行时，攻击者可能利用 Werkzeug 调试器执行任意代码，构成严重安全风险。
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/flask-debug
 * @tags security
 *       external/cwe/cwe-215
 *       external/cwe/cwe-489
 */

import python  // Python 代码分析的基础库
import semmle.python.dataflow.new.DataFlow  // 提供数据流分析能力
import semmle.python.ApiGraphs  // API 调用图分析支持
import semmle.python.frameworks.Flask  // Flask 框架特定分析

// 查找所有以调试模式运行的 Flask 应用
from API::CallNode flaskAppRunCall, ImmutableLiteral debugParamValue
where
  // 检查 debug 参数是否显式设置为 true
  debugParamValue.booleanValue() = true and
  // 确认是 Flask 应用实例的 run 方法调用
  flaskAppRunCall = Flask::FlaskApp::instance().getMember("run").getACall() and
  // 获取 debug 参数的值
  debugParamValue = flaskAppRunCall.getParameter(2, "debug").getAValueReachingSink().asExpr()
select flaskAppRunCall,
  // 报告发现的安全问题
  "检测到 Flask 应用以调试模式运行。这可能导致攻击者通过调试器执行任意代码。"