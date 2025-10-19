/**
 * @name Use of insecure SSL/TLS version
 * @description Using an insecure SSL/TLS version may leave the connection vulnerable to attacks.
 * @id py/insecure-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

import python
import semmle.python.dataflow.new.DataFlow
import FluentApiModel

/* 表示可能使用不安全SSL/TLS版本的协议配置节点 */
class ProtocolConfiguration extends DataFlow::Node {
  ProtocolConfiguration() {
    /* 情况1：使用上下文创建不安全连接 */
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    /* 情况2：不使用上下文创建不安全连接 */
    unsafe_connection_creation_without_context(this, _)
    or
    /* 情况3：创建不安全上下文 */
    unsafe_context_creation(this, _)
  }

  /* 获取与此配置关联的函数节点 */
  DataFlow::Node getAssociatedFunction() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

/* 表示可命名的节点（函数调用或属性引用） */
class NameableNode extends DataFlow::Node {
  NameableNode() {
    /* 情况1：节点是协议配置中的函数 */
    this = any(ProtocolConfiguration pc).getAssociatedFunction()
    or
    /* 情况2：节点是另一个可命名节点的属性引用 */
    this = any(NameableNode attr).(DataFlow::AttrRef).getObject()
  }
}

/* 获取可命名节点的限定名称 */
string getQualifiedName(NameableNode node) {
  /* 情况1：直接函数名 */
  result = node.asExpr().(Name).getId()
  or
  /* 情况2：属性访问链 */
  exists(DataFlow::AttrRef attrRef | attrRef = node |
    result = getQualifiedName(attrRef.getObject()) + "." + attrRef.getAttributeName()
  )
}

/* 获取协议配置的描述性名称 */
string getConfigurationName(ProtocolConfiguration configNode) {
  /* 情况1：函数调用配置 */
  result = "call to " + getQualifiedName(configNode.(DataFlow::CallCfgNode).getFunction())
  or
  /* 情况2：上下文修改（非调用、非上下文创建） */
  not configNode instanceof DataFlow::CallCfgNode and
  not configNode instanceof ContextCreation and
  result = "context modification"
}

/* 根据特定性标志获取适当的动词 */
string getVerb(boolean isSpecific) {
  isSpecific = true and result = "specified"
  or
  isSpecific = false and result = "allowed"
}

/* 检测不安全SSL/TLS版本使用情况的查询 */
from
  DataFlow::Node insecureConnectionNode, string insecureProtocolVersion, 
  ProtocolConfiguration protocolConfigNode, boolean isSpecificVersion
where
  /* 情况1：使用上下文创建不安全连接 */
  (
    unsafe_connection_creation_with_context(insecureConnectionNode, insecureProtocolVersion, protocolConfigNode, isSpecificVersion)
  )
  or
  /* 情况2：不使用上下文创建不安全连接 */
  (
    unsafe_connection_creation_without_context(insecureConnectionNode, insecureProtocolVersion) and
    protocolConfigNode = insecureConnectionNode and
    isSpecificVersion = true
  )
  or
  /* 情况3：创建不安全上下文 */
  (
    unsafe_context_creation(protocolConfigNode, insecureProtocolVersion) and
    insecureConnectionNode = protocolConfigNode and
    isSpecificVersion = true
  )
select insecureConnectionNode,
  "Insecure SSL/TLS protocol version " + insecureProtocolVersion + " " + getVerb(isSpecificVersion) + " by $@.",
  protocolConfigNode, getConfigurationName(protocolConfigNode)