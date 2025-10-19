/**
 * @name IP地址欺骗
 * @description 从HTTP头中读取远程端点标识符。攻击者可以修改该标识符的值以伪造客户端IP。
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id py/ip-address-spoofing
 * @tags security
 *       experimental
 *       external/cwe/cwe-348
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.ApiGraphs
import ClientSuppliedIpUsedInSecurityCheckLib
import ClientSuppliedIpUsedInSecurityCheckFlow::PathGraph

/**
 * 一个污点跟踪配置，用于追踪从HTTP头获取客户端IP到敏感用途的流动。
 */
private module ClientSuppliedIpUsedInSecurityCheckConfig implements DataFlow::ConfigSig {
  // 判断是否为源节点
  predicate isSource(DataFlow::Node source) {
    source instanceof ClientSuppliedIpUsedInSecurityCheck
  }

  // 判断是否为汇节点
  predicate isSink(DataFlow::Node sink) { sink instanceof PossibleSecurityCheck }

  // 判断是否为额外的流动步骤
  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    exists(DataFlow::CallCfgNode ccn |
      ccn = API::moduleImport("netaddr").getMember("IPAddress").getACall() and
      ccn.getArg(0) = pred and
      ccn = succ
    )
  }

  // 判断是否为屏障节点
  predicate isBarrier(DataFlow::Node node) {
    // `client_supplied_ip.split(",")[n]` for `n` > 0
    exists(Subscript ss |
      not ss.getIndex().(IntegerLiteral).getText() = "0" and
      ss.getObject().(Call).getFunc().(Attribute).getName() = "split" and
      ss.getObject().(Call).getAnArg().(StringLiteral).getText() = "," and
      ss = node.asExpr()
    )
  }

  // 观察差异信息增量模式
  predicate observeDiffInformedIncrementalMode() { any() }
}

/** 全局污点跟踪，用于检测“客户端IP用于安全检查”漏洞。 */
module ClientSuppliedIpUsedInSecurityCheckFlow =
  TaintTracking::Global<ClientSuppliedIpUsedInSecurityCheckConfig>;

from
  ClientSuppliedIpUsedInSecurityCheckFlow::PathNode source,
  ClientSuppliedIpUsedInSecurityCheckFlow::PathNode sink
where ClientSuppliedIpUsedInSecurityCheckFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "IP地址欺骗可能包括来自$@的代码。",
  source.getNode(), "此用户输入"
