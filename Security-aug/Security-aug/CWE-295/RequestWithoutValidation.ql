/**
 * @name Request without certificate validation
 * @description Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/request-without-cert-validation
 * @tags security
 *       external/cwe/cwe-295
 */

import python
private import semmle.python.dataflow.new.DataFlow // 导入数据流分析库，用于追踪数据流
private import semmle.python.Concepts // 导入Python概念库，用于处理Python代码中的概念

from
  Http::Client::Request request, // 定义一个变量request，表示HTTP客户端的请求
  DataFlow::Node disablingNode, // 定义一个变量disablingNode，表示禁用证书验证的数据流节点
  DataFlow::Node origin, // 定义一个变量origin，表示数据流的起点
  string ending // 定义一个字符串变量ending，用于存储结果中的结尾部分
where
  request.disablesCertificateValidation(disablingNode, origin) and // 条件：请求禁用了证书验证，并且找到禁用证书验证的数据流节点和起点
  // Showing the origin is only useful when it's a different node than the one disabling
  // certificate validation, for example in `requests.get(..., verify=arg)`, `arg` would
  // be the `disablingNode`, and the `origin` would be the place were `arg` got its
  // value from.
  if disablingNode = origin then ending = "." else ending = " by $@." // 如果禁用节点和起点相同，则设置ending为"."，否则设置为" by $@."
select request, "This request may run without certificate validation because $@" + ending, // 选择请求并生成警告信息
  disablingNode, "it is disabled", origin, "this value" // 附加禁用节点和起点的信息
