/**
 * @name CORS策略配置不当导致的绕过漏洞
 * @description 在验证用户提供的Origin头部时，若采用弱字符串比较方法（例如'string.startswith'），
 *              可能会使得CORS安全机制失效，从而允许攻击者发起跨域请求。
 * @kind path-problem
 * @problem.severity warning
 * @id py/cors-bypass
 * @tags security
 *       externa/cwe/CWE-346
 */

import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Flow
import semmle.python.dataflow.new.RemoteFlowSources

/**
 * 检测字符串中是否存在与CORS相关的关键词
 * 该谓词用于启发式地识别涉及CORS的变量和代码片段
 */
bindingset[s]
predicate containsCorsKeywords(string s) { s.matches(["%origin%", "%cors%"]) }

/**
 * 描述调用字符串startswith方法的控制流节点
 * 此类调用常被错误地用于Origin头部的验证，从而引发安全问题
 */
private class StrStartswithMethodCall extends ControlFlowNode {
  StrStartswithMethodCall() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 判断变量名称中是否包含CORS相关关键词
 */
private predicate hasCorsRelevantName(Variable var) { 
  containsCorsKeywords(var.getId()) 
}

/**
 * 判断控制流节点是否关联于CORS验证逻辑
 * 采用三种启发式规则来识别潜在相关节点，以降低误报率
 */
private predicate isCorsRelevantNode(ControlFlowNode cfgNode) {
  // 规则1：调用startswith方法的变量名包含CORS关键词（作为方法调用者）
  exists(string varName | 
    containsCorsKeywords(varName) and 
    cfgNode.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = varName
  )
  or
  // 规则2：作为startswith方法参数的变量名包含CORS关键词
  exists(string varName | 
    containsCorsKeywords(varName) and 
    cfgNode.(CallNode).getArg(0).(NameNode).getId() = varName
  )
  or
  // 规则3：值被写入包含CORS关键词的变量（潜在源点）
  exists(Variable var | 
    hasCorsRelevantName(var) and 
    cfgNode.getASuccessor*().getNode() = var.getAStore()
  )
}

/**
 * 代表CherryPy框架中请求对象的成员访问点
 * 这些成员被视作远程流源，因为它们承载了用户输入的数据
 */
class CherryPyRequestMember extends RemoteFlowSource::Range {
  CherryPyRequestMember() {
    this =
      API::moduleImport("cherrypy")
          .getMember("request")
          .getMember([
              "charset", "content_type", "filename", "fp", "name", "params", "headers", "length"
            ])
          .asSource()
  }

  override string getSourceType() { result = "cherrypy.request" }
}

/**
 * 针对CORS策略绕过漏洞的数据流分析配置
 * 通过定义源点、汇点及额外的流传播步骤，来识别不安全的Origin验证模式
 */
module CorsBypassAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 指定数据流源：涵盖所有远程输入源
   */
  predicate isSource(DataFlow::Node dataNode) { 
    dataNode instanceof RemoteFlowSource 
  }

  /**
   * 指定数据流汇：字符串startswith方法的调用对象或其参数
   * 这些位置常用于不安全的Origin头部验证
   */
  predicate isSink(DataFlow::Node dataNode) {
    exists(StrStartswithMethodCall startswithCall |
      dataNode.asCfgNode() = startswithCall.(CallNode).getArg(0) or
      dataNode.asCfgNode() = startswithCall.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外的数据流传播步骤：处理cherrypy.request.headers.get()方法调用
   * 此类调用模式常用于从请求中获取头部信息
   */
  predicate isAdditionalFlowStep(DataFlow::Node srcNode, DataFlow::Node tgtNode) {
    exists(API::CallNode apiCall, API::Node headersNode |
      headersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      apiCall = headersNode.getMember("get").getACall()
    |
      apiCall.getReturn().asSource() = tgtNode and 
      headersNode.asSource() = srcNode
    )
  }

  // 启用增量模式差异观察以提高分析效率
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块，用于追踪从源到汇的数据流
module CorsTaintFlow = TaintTracking::Global<CorsBypassAnalysisConfig>;

import CorsTaintFlow::PathGraph

/**
 * 检测潜在的CORS策略绕过漏洞
 * 识别从用户输入源到不安全字符串比较操作的数据流路径
 */
from CorsTaintFlow::PathNode sourcePathNode, CorsTaintFlow::PathNode sinkPathNode
where
  CorsTaintFlow::flowPath(sourcePathNode, sinkPathNode) and
  (
    isCorsRelevantNode(sourcePathNode.getNode().asCfgNode())
    or
    isCorsRelevantNode(sinkPathNode.getNode().asCfgNode())
  )
select sinkPathNode, sourcePathNode, sinkPathNode,
  "使用弱字符串比较验证 Origin 头部可能导致 CORS 策略被绕过。"