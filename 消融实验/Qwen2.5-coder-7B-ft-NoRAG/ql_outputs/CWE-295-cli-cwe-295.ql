/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation. Making a request without certificate validation can allow man-in-the-middle attacks.
 * @id py/cli-cwe-295
 */
import python
import semmle.python.dataflow.new.DataFlow

// 定义数据流源节点和汇节点的变量
from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin, string ending
// 条件：请求禁用了证书验证，并且找到禁用证书验证的数据流节点和起点
where
  request.disablesCertificateValidation(disablingNode, origin) and
  // 显示原始节点只有在它与禁用证书验证的节点不同时才有用，例如在 `requests.get(..., verify=arg)` 中，
  // `arg` 将是 `disablingNode`，而 `origin` 将是 `arg` 的来源位置。
  if disablingNode = origin then ending = "." else ending = " by $@."

// 选择结果：汇节点、源节点、路径信息以及描述信息
select request, disablingNode, origin, "Request made without certificate validation" + ending