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

// ProtocolConfiguration类用于表示协议配置节点，继承自DataFlow::Node。
class ProtocolConfiguration extends DataFlow::Node {
  // 构造函数，定义了三种情况下的ProtocolConfiguration实例。
  ProtocolConfiguration() {
    // 使用上下文创建不安全的连接。
    unsafe_connection_creation_with_context(_, _, this, _)
    or
    // 不使用上下文创建不安全的连接。
    unsafe_connection_creation_without_context(this, _)
    or
    // 创建不安全的上下文。
    unsafe_context_creation(this, _)
  }

  // 获取当前节点对应的函数节点。
  DataFlow::Node getNode() { result = this.(DataFlow::CallCfgNode).getFunction() }
}

// Nameable类用于表示可以命名的节点，继承自DataFlow::Node。
class Nameable extends DataFlow::Node {
  // 构造函数，定义了两种情况下的Nameable实例。
  Nameable() {
    // 当前节点是任何ProtocolConfiguration节点的函数节点。
    this = any(ProtocolConfiguration pc).getNode()
    or
    // 当前节点是任何Nameable对象的属性引用。
    this = any(Nameable attr).(DataFlow::AttrRef).getObject()
  }
}

// 返回给定Nameable对象的调用名称。
string callName(Nameable call) {
  // 如果call是一个名称表达式，则返回其ID。
  result = call.asExpr().(Name).getId()
  or
  // 如果call是一个属性引用，则返回其对象的名称加上属性名。
  exists(DataFlow::AttrRef a | a = call |
    result = callName(a.getObject()) + "." + a.getAttributeName()
  )
}

// 返回给定ProtocolConfiguration对象的配置名称。
string configName(ProtocolConfiguration protocolConfiguration) {
  // 如果protocolConfiguration是一个函数调用节点，则返回其调用名称。
  result = "call to " + callName(protocolConfiguration.(DataFlow::CallCfgNode).getFunction())
  or
  // 如果protocolConfiguration不是函数调用节点且不是上下文创建节点，则返回"context modification"。
  not protocolConfiguration instanceof DataFlow::CallCfgNode and
  not protocolConfiguration instanceof ContextCreation and
  result = "context modification"
}

// 根据specific布尔值返回相应的动词。
string verb(boolean specific) {
  // 如果specific为true，则返回"specified"。
  specific = true and result = "specified"
  or
  // 如果specific为false，则返回"allowed"。
  specific = false and result = "allowed"
}

// 查询语句，查找不安全的SSL/TLS版本使用情况。
from
  DataFlow::Node connectionCreation, string insecure_version, DataFlow::Node protocolConfiguration,
  boolean specific
where
  // 查找使用上下文创建不安全连接的情况。
  unsafe_connection_creation_with_context(connectionCreation, insecure_version,
    protocolConfiguration, specific)
  or
  // 查找不使用上下文创建不安全连接的情况。
  unsafe_connection_creation_without_context(connectionCreation, insecure_version) and
  protocolConfiguration = connectionCreation and
  specific = true
  or
  // 查找创建不安全上下文的情况。
  unsafe_context_creation(protocolConfiguration, insecure_version) and
  connectionCreation = protocolConfiguration and
  specific = true
select connectionCreation,
  // 选择不安全连接创建节点、描述信息、协议配置节点及其配置名称。
  "Insecure SSL/TLS protocol version " + insecure_version + " " + verb(specific) + " by $@.",
  protocolConfiguration, configName(protocolConfiguration)
