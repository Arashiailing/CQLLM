/**
 * @name Flask app is run in debug mode
 * @description Running a Flask app in debug mode may allow an attacker to run arbitrary code through the Werkzeug debugger.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/flask-debug
 * @tags security
 *       external/cwe/cwe-215
 *       external/cwe/cwe-489
 */

import python  # 导入python库，用于分析Python代码
import semmle.python.dataflow.new.DataFlow  # 导入数据流分析库
import semmle.python.ApiGraphs  # 导入API图分析库
import semmle.python.frameworks.Flask  # 导入Flask框架分析库

# 从API调用节点中选择调用
from API::CallNode call
where
  # 检查是否为Flask应用实例的run方法调用，并且第二个参数（debug）为true
  call = Flask::FlaskApp::instance().getMember("run").getACall() and
  call.getParameter(2, "debug").getAValueReachingSink().asExpr().(ImmutableLiteral).booleanValue() = true
select call,
  # 选择符合条件的调用并输出警告信息
  "A Flask app appears to be run in debug mode. This may allow an attacker to run arbitrary code through the debugger."
