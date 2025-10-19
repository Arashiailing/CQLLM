/**
 * @name Initializing SECRET_KEY of Flask application with Constant value
 * @description Initializing SECRET_KEY of Flask application with Constant value
 * files can lead to Authentication bypass
 * @kind path-problem
 * @id py/flask-constant-secret-key
 * @problem.severity error
 * @security-severity 8.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-287
 */

import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking
import WebAppConstantSecretKeyDjango
import WebAppConstantSecretKeyFlask
import semmle.python.filters.Tests

// 定义一个新的类型 TFrameWork，可以是 Flask 或 Django
newtype TFrameWork =
  Flask() or
  Django()

// 私有模块 WebAppConstantSecretKeyConfig 实现了 DataFlow::StateConfigSig 接口
private module WebAppConstantSecretKeyConfig implements DataFlow::StateConfigSig {
  // 定义一个类 FlowState，其类型为 TFrameWork
  class FlowState = TFrameWork;

  // 定义 isSource 谓词，用于判断数据流的源节点
  predicate isSource(DataFlow::Node source, FlowState state) {
    // 如果状态是 Flask，则调用 FlaskConstantSecretKeyConfig::isSource 方法判断源节点
    state = Flask() and FlaskConstantSecretKeyConfig::isSource(source)
    // 如果状态是 Django，则调用 DjangoConstantSecretKeyConfig::isSource 方法判断源节点
    or
    state = Django() and DjangoConstantSecretKeyConfig::isSource(source)
  }

  // 定义 isBarrier 谓词，用于判断数据流的屏障节点
  predicate isBarrier(DataFlow::Node node) {
    // 如果节点在标准库中，则为屏障节点
    node.getLocation().getFile().inStdlib()
    // 为了减少误报率，添加以下条件
    or
    node.getLocation()
        .getFile()
        .getRelativePath()
        .matches(["%test%", "%demo%", "%example%", "%sample%"]) and
    // 但是这也意味着查询测试中的所有数据流节点都被排除了...因此我们添加了这个：
    not node.getLocation().getFile().getRelativePath().matches("%query-tests/Security/CWE-287%")
  }

  // 定义 isSink 谓词，用于判断数据流的汇节点
  predicate isSink(DataFlow::Node sink, FlowState state) {
    // 如果状态是 Flask，则调用 FlaskConstantSecretKeyConfig::isSink 方法判断汇节点
    state = Flask() and FlaskConstantSecretKeyConfig::isSink(sink)
    // 如果状态是 Django，则调用 DjangoConstantSecretKeyConfig::isSink 方法判断汇节点
    or
    state = Django() and DjangoConstantSecretKeyConfig::isSink(sink)
  }

  // 定义 observeDiffInformedIncrementalMode 谓词，用于观察差异信息增量模式
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 定义 WebAppConstantSecretKeyFlow 模块，使用 TaintTracking::GlobalWithState 进行全局状态跟踪
module WebAppConstantSecretKeyFlow = TaintTracking::GlobalWithState<WebAppConstantSecretKeyConfig>;

// 导入 WebAppConstantSecretKeyFlow::PathGraph
import WebAppConstantSecretKeyFlow::PathGraph

// 从 WebAppConstantSecretKeyFlow::PathNode 中选择源节点和汇节点，并生成相应的查询结果
from WebAppConstantSecretKeyFlow::PathNode source, WebAppConstantSecretKeyFlow::PathNode sink
where WebAppConstantSecretKeyFlow::flowPath(source, sink)
select sink, source, sink, "The SECRET_KEY config variable is assigned by $@.", source,
  " this constant String"
