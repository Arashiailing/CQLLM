/**
 * @name CORS策略配置不当导致的绕过漏洞
 * @description 当使用弱字符串比较方法（如'string.startswith'）验证用户提供的Origin头部时，
 *              可能导致CORS安全机制失效，使攻击者能够发起跨域请求。
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
 * 检查字符串是否包含CORS相关关键词
 * 该谓词用于启发式识别涉及CORS的变量和代码片段
 */
bindingset[inputStr]
predicate containsCorsKeywords(string inputStr) { inputStr.matches(["%origin%", "%cors%"]) }

/**
 * 表示调用字符串startswith方法的控制流节点
 * 此类调用常被错误地用于Origin头部验证，引发安全问题
 */
private class StrStartswithMethodCall extends ControlFlowNode {
  StrStartswithMethodCall() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 判断变量名称是否包含CORS相关关键词
 */
private predicate hasCorsRelevantName(Variable variable) { 
  containsCorsKeywords(variable.getId()) 
}

/**
 * 判断控制流节点是否关联CORS验证逻辑
 * 采用三种启发式规则识别潜在相关节点，降低误报率
 */
private predicate isCorsRelevantNode(ControlFlowNode node) {
  // 规则3：值被写入包含CORS关键词的变量（潜在源点）
  exists(Variable variable | 
    hasCorsRelevantName(variable) and 
    node.getASuccessor*().getNode() = variable.getAStore()
  )
  or
  // 规则1：调用startswith方法的变量名包含CORS关键词（作为方法调用者）
  exists(string variableName | 
    containsCorsKeywords(variableName) and 
    node.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = variableName
  )
  or
  // 规则2：作为startswith方法参数的变量名包含CORS关键词
  exists(string variableName | 
    containsCorsKeywords(variableName) and 
    node.(CallNode).getArg(0).(NameNode).getId() = variableName
  )
}

/**
 * 代表CherryPy框架中请求对象的成员访问点
 * 这些成员被视作远程流源，因为它们承载用户输入数据
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
 * CORS策略绕过漏洞的数据流分析配置
 * 通过定义源点、汇点及额外流传播步骤，识别不安全的Origin验证模式
 */
module CorsBypassAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 指定数据流源：涵盖所有远程输入源
   */
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource 
  }

  /**
   * 指定数据流汇：字符串startswith方法的调用对象或其参数
   * 这些位置常用于不安全的Origin头部验证
   */
  predicate isSink(DataFlow::Node sinkNode) {
    exists(StrStartswithMethodCall callNode |
      sinkNode.asCfgNode() = callNode.(CallNode).getArg(0) or
      sinkNode.asCfgNode() = callNode.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外的数据流传播步骤：处理cherrypy.request.headers.get()方法调用
   * 此类调用模式常用于从请求中获取头部信息
   */
  predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
    exists(API::CallNode call, API::Node headers |
      headers = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      call = headers.getMember("get").getACall()
    |
      call.getReturn().asSource() = toNode and 
      headers.asSource() = fromNode
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