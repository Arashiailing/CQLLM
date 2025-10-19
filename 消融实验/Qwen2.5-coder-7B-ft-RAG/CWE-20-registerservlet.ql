/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/registerservlet
 * @tags security
 *       external/cwe/cwe-089
 */

import python  // 导入Python库，用于处理Python代码的解析和分析
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析模块
import semmle.python.ApiGraphs  // 导入API图模块，用于分析API调用
import semmle.python.dataflow.new.Concepts  // 导入概念模块，用于表示数据流元素

// 定义查询谓词，查找Servlet注册过程中存在的安全漏洞
predicate registerservlet(DataFlow::CallCfgNode servletRegistrationCall, String servletName) {
  // 条件1：调用的是正确的Servlet类方法
  servletRegistrationCall = ApiGraphs::getApiCall(
    "javax.servlet.ServletContext", "addServlet", _,
    [_, servletName, _]
  )
  // 条件2：Servlet名称不是常量值
  or
  servletRegistrationCall = ApiGraphs::getApiCall(
    "javax.servlet.http.HttpServlet", "service", _,
    [_, servletName, _]
  )
  // 条件3：Servlet名称是变量值
}

// 定义查询谓词，查找可能存在安全漏洞的Servlet注册调用
predicate vulnerableRegisterCall(DataFlow::CallCfgNode servletRegistrationCall, String servletName) {
  registerservlet(servletRegistrationCall, servletName)
  // 筛选：Servlet名称不为空且未经过安全验证
  not exists(StringLiteral safeServletName | safeServletName = servletName |
    safeServletName.getText() = _
  )
}

// 定义查询谓词，查找具有安全漏洞的Servlet注册调用及其详细信息
predicate unsafeServletRegistration(DataFlow::CallCfgNode servletRegistrationCall, String servletName) {
  vulnerableRegisterCall(servletRegistrationCall, servletName)
  // 条件：存在从用户输入到Servlet名称的数据流路径
  exists(DataFlow::Node servletInputSource | servletInputSource = servletRegistrationCall.getArg(0) |
    servletInputSource.(ImmutableLiteral).booleanValue() = false  // 排除常量值
  )
}

// 主查询：查找存在安全漏洞的Servlet注册调用及其相关信息
from DataFlow::CallCfgNode servletRegistrationCall, String servletName
where unsafeServletRegistration(servletRegistrationCall, servletName)
select servletRegistrationCall.asExpr(),
  "Servlet registration depends on a $@ which may contain invalid data.", servletInputSource,
  servletInputSource.(ImmutableLiteral), servletName