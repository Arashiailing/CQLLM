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
 * Jinja 2 API Reference:
 * Environment: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment
 * Template: https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Template
 * 
 * Note: autoescape is a valid parameter for both Environment and Template constructors
 * Example vulnerable usage:
 *   unsafe_tmpl = Template('Hello {{ name }}!', autoescape=False)
 */

// 获取Jinja2核心构造函数的API节点
private API::Node jinja2Constructor() {
  result = API::moduleImport("jinja2").getMember("Environment")
  or
  result = API::moduleImport("jinja2").getMember("Template")
}

from API::CallNode constructorCall
where
  // 识别Jinja2构造函数调用
  constructorCall = jinja2Constructor().getACall()
  and
  // 排除使用可变参数(*args)的调用
  not exists(constructorCall.asCfgNode().(CallNode).getNode().getStarargs())
  and
  // 排除使用关键字参数字典(**kwargs)的调用
  not exists(constructorCall.asCfgNode().(CallNode).getNode().getKwargs())
  and
  (
    // 情况1：未显式设置autoescape参数
    not exists(constructorCall.getArgByName("autoescape"))
    or
    // 情况2：显式设置autoescape=False
    constructorCall.getKeywordParameter("autoescape")
        .getAValueReachingSink()
        .asExpr()
        .(ImmutableLiteral)
        .booleanValue() = false
  )
select constructorCall, "Using jinja2 templates with autoescape=False can potentially allow XSS attacks."