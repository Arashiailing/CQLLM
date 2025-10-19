/**
 * @name Predictable token
 * @description Tokens used for sensitive tasks, such as, password recovery,
 *  and email confirmation, should not use predictable values.
 * @kind path-problem
 * @precision medium
 * @problem.severity error
 * @security-severity 5
 * @id py/predictable-token
 * @tags security
 *       experimental
 *       external/cwe/cwe-340
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking

// 定义一个类，用于表示可预测结果的源节点
class PredictableResultSource extends DataFlow::Node {
  // 构造函数，初始化PredictableResultSource对象
  PredictableResultSource() {
    // 检查是否存在API调用返回值，该返回值是uuid1、uuid3或uuid5方法的返回值
    exists(API::Node uuidCallRet |
      uuidCallRet = API::moduleImport("uuid").getMember(["uuid1", "uuid3", "uuid5"]).getReturn()
    )
    // 如果存在上述返回值，则将其作为数据流的源节点
    |
      this = uuidCallRet.asSource()
      // 或者将返回值的成员（如hex、bytes、bytes_le）作为数据流的源节点
      or
      this = uuidCallRet.getMember(["hex", "bytes", "bytes_le"]).asSource()
    )
  }
}

// 定义一个类，用于表示令牌赋值的值汇节点
class TokenAssignmentValueSink extends DataFlow::Node {
  // 构造函数，初始化TokenAssignmentValueSink对象
  TokenAssignmentValueSink() {
    // 检查是否存在名称匹配"%token"或"%code"的字符串
    exists(string name | name.toLowerCase().matches(["%token", "%code"]) |
      // 如果存在这样的字符串，则检查其是否为变量名或属性名
      exists(DefinitionNode n | n.getValue() = this.asCfgNode() | name = n.(NameNode).getId())
      or
      exists(DataFlow::AttrWrite aw | aw.getValue() = this | name = aw.getAttributeName())
    )
  }
}

// 定义一个模块，用于配置数据流分析的规则
private module TokenBuiltFromUuidConfig implements DataFlow::ConfigSig {
  // 判断节点是否为源节点
  predicate isSource(DataFlow::Node source) { source instanceof PredictableResultSource }

  // 判断节点是否为汇节点
  predicate isSink(DataFlow::Node sink) { sink instanceof TokenAssignmentValueSink }

  // 判断节点之间的流动步骤是否为额外的流动步骤
  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    // 检查是否存在内置函数str的调用，并且nodeFrom是该调用的第一个参数，nodeTo是该调用本身
    exists(DataFlow::CallCfgNode call |
      call = API::builtin("str").getACall() and
      nodeFrom = call.getArg(0) and
      nodeTo = call
    )
  }

  // 观察差异信息增量模式
  predicate observeDiffInformedIncrementalMode() { any() }
}

/** Global taint-tracking for detecting "TokenBuiltFromUUID" vulnerabilities. */
// 定义全局污点跟踪模块，用于检测“TokenBuiltFromUUID”漏洞
module TokenBuiltFromUuidFlow = TaintTracking::Global<TokenBuiltFromUuidConfig>;

import TokenBuiltFromUuidFlow::PathGraph

// 查询语句：从源节点到汇节点的路径中选择相关节点和信息
from TokenBuiltFromUuidFlow::PathNode source, TokenBuiltFromUuidFlow::PathNode sink
where TokenBuiltFromUuidFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Token built from $@.", source.getNode(), "predictable value"
