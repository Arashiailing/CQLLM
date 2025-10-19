/**
 * @name Jinja2 templating with autoescape=False
 * @description Using jinja2 templates with 'autoescape=False' can
 *              cause a cross-site scripting vulnerability.
 * @kind problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision medium
 * @id py/jinja2/autoescape-false
 * @tags security
 *       external/cwe/cwe-079
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

/*
 * Jinja 2 Docs:
 * https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 *
 * Although the docs doesn't say very clearly, autoescape is a valid argument when constructing
 * a Template manually
 *
 * unsafe_tmpl = Template('Hello {{ name }}!')
 * safe1_tmpl = Template('Hello {{ name }}!', autoescape=True)
 */

// 定义一个私有函数，用于获取Jinja2的Environment或Template对象
private API::Node jinja2EnvironmentOrTemplate() {
  // 尝试获取jinja2模块中的Environment成员
  result = API::moduleImport("jinja2").getMember("Environment")
  // 如果获取失败，则尝试获取jinja2模块中的Template成员
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

// 从API::CallNode类型的call节点开始查询
from API::CallNode call
where
  // 检查call是否是jinja2EnvironmentOrTemplate函数返回的对象的调用
  call = jinja2EnvironmentOrTemplate().getACall() and
  // 确保调用中没有星号参数（*args）
  not exists(call.asCfgNode().(CallNode).getNode().getStarargs()) and
  // 确保调用中没有关键字参数（**kwargs）
  not exists(call.asCfgNode().(CallNode).getNode().getKwargs()) and
  (
    // 检查调用中是否不存在名为autoescape的参数
    not exists(call.getArgByName("autoescape"))
    // 或者检查autoescape参数的值是否为false
    or
    call.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select call, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."
// 选择符合条件的call节点，并报告使用jinja2模板时autoescape设置为False可能导致跨站脚本攻击的问题。
