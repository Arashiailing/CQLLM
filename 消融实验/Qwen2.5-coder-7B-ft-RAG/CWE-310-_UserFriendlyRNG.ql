/**
 * @name Weak sensitive data hashing
 * @description Using a weak hashing algorithm for sensitive data reduces its entropy,
 *              making it easier to break.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/weak-sensitive-data-hashing
 * @tags security
 *       external/cwe/cwe-310
 */

// 导入用于敏感数据哈希分析的专用模块
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery

// 导入路径图类，用于表示数据流路径
import WeakSensitiveDataHashingFlow::PathGraph

// 从路径图中选择源节点和汇节点
from WeakSensitiveDataHashingFlow::PathNode source, WeakSensitiveDataHashingFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where WeakSensitiveDataHashingFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、路径信息、描述信息等
select sink.getNode(), source, sink, "Hash function uses $@", source.getNode(),
  "a weak hashing algorithm"