/**
 * @name Untrusted data passed to external API
 * @description Data provided remotely is used in this external API without sanitization, which could be a security risk.
 * @id py/untrusted-data-to-external-api
 * @kind path-problem
 * @precision low
 * @problem.severity error
 * @security-severity 7.8
 * @tags security external/cwe/cwe-20
 */

// 导入Python库，用于处理Python代码的解析和分析
import python
// 导入外部API库，用于识别外部API调用
import ExternalAPIs
// 导入路径图类，用于跟踪数据流路径
import UntrustedDataToExternalApiFlow::PathGraph

// 从UntrustedDataToExternalApiFlow模块中引入PathNode类，表示数据流路径中的节点
from
  UntrustedDataToExternalApiFlow::PathNode source, // 源节点，表示不信任数据的起始点
  UntrustedDataToExternalApiFlow::PathNode sink,   // 汇节点，表示不信任数据的终点（即外部API调用）
  ExternalApiUsedWithUntrustedData externalApi    // 外部API调用，使用了不信任的数据
where
  // 条件1：汇节点必须是外部API调用中使用的不信任数据节点
  sink.getNode() = externalApi.getUntrustedDataNode() and
  // 条件2：存在从源节点到汇节点的数据流路径
  UntrustedDataToExternalApiFlow::flowPath(source, sink)
select
  // 选择要报告的结果，包括汇节点、源节点、汇节点、外部API调用的描述信息以及源节点的详细信息
  sink.getNode(), source, sink,
  "Call to " + externalApi.toString() + " with untrusted data from $@.", source.getNode(),
  source.toString()
