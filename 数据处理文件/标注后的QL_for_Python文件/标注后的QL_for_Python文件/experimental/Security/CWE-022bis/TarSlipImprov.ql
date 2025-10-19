/**
 * @name Arbitrary file write during tarfile extraction
 * @description 提取恶意tar存档中的文件时，如果不验证目标文件路径是否在目标目录内，可能会导致目标目录外的文件被覆盖。
 * @kind path-problem
 * @id py/tarslip-extended
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import TarSlipImprovFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.internal.Attributes
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.dataflow.new.RemoteFlowSources

/**
 * 处理Tarfile打开的三种情况：
 *  - `tarfile.open()`
 *  - `tarfile.TarFile()`
 *  - `MKtarfile.Tarfile.open()`
 */
API::Node tarfileOpen() {
  result in [
      API::moduleImport("tarfile").getMember(["open", "TarFile"]), // 获取tarfile模块中的open和TarFile成员
      API::moduleImport("tarfile").getMember("TarFile").getASubclass().getMember("open") // 获取tarfile模块中TarFile子类的open成员
    ]
}

/**
 * 处理前面提到的三种情况，以及在这些情况下使用`closing`的情况
 */
class AllTarfileOpens extends API::CallNode {
  AllTarfileOpens() {
    this = tarfileOpen().getACall() // 匹配tarfileOpen()的调用
    or
    exists(API::Node closing, Node arg |
      closing = API::moduleImport("contextlib").getMember("closing") and // 检查contextlib模块中的closing成员
      this = closing.getACall() and // 匹配closing的调用
      arg = this.getArg(0) and // 获取closing的第一个参数
      arg = tarfileOpen().getACall() // 检查第一个参数是否是tarfileOpen()的调用
    )
  }
}

/**
 * 用于检测更多“TarSlip”漏洞的污点跟踪配置。
 */
private module TarSlipImprovConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source = tarfileOpen().getACall() } // 定义源节点为tarfileOpen()的调用

  predicate isSink(DataFlow::Node sink) {
    (
      // 捕获没有`members`参数的`extractall`方法调用的接收器。
      // 对于没有`members`参数的`file.extractall`调用，`file`被视为接收器。
      exists(MethodCallNode call, AllTarfileOpens atfo |
        call = atfo.getReturn().getMember("extractall").getACall() and // 匹配返回对象的extractall方法调用
        not exists(Node arg | arg = call.getArgByName("members")) and // 确保没有提供members参数
        sink = call.getObject() // 将调用对象视为接收器
      )
      or
      // 捕获有`members`参数的`extractall`方法调用的接收器。
      // 对于有`members`参数的`file.extractall`调用，如果`members`参数不是None、List或`getmembers`方法调用，则`members`参数被视为接收器。
      // 否则，调用对象被视为接收器。
      exists(MethodCallNode call, Node arg, AllTarfileOpens atfo |
        call = atfo.getReturn().getMember("extractall").getACall() and // 匹配返回对象的extractall方法调用
        arg = call.getArgByName("members") and // 获取members参数
        if
          arg.asCfgNode() instanceof NameConstantNode or // 如果members参数是常量None
          arg.asCfgNode() instanceof ListNode // 如果members参数是列表
        then sink = call.getObject() // 将调用对象视为接收器
        else
          if arg.(MethodCallNode).getMethodName() = "getmembers" // 如果members参数是getmembers方法调用
          then sink = arg.(MethodCallNode).getObject() // 将getmembers方法的调用对象视为接收器
          else sink = call.getArgByName("members") // 否则将members参数视为接收器
      )
      or
      // `extract`方法的参数被视为接收器。
      exists(AllTarfileOpens atfo |
        sink = atfo.getReturn().getMember("extract").getACall().getArg(0) // 匹配返回对象的extract方法调用并获取其第一个参数
      )
      or
      // `_extract_member`方法的参数被视为接收器。
      exists(MethodCallNode call, AllTarfileOpens atfo |
        call = atfo.getReturn().getMember("_extract_member").getACall() and // 匹配返回对象的_extract_member方法调用
        call.getArg(1).(AttrRead).accesses(sink, "name") // 获取第二个参数并访问其name属性
      )
    ) and
    not sink.getScope().getLocation().getFile().inStdlib() // 确保接收器不在标准库中
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    nodeTo.(MethodCallNode).calls(nodeFrom, "getmembers") and // 如果nodeTo调用了nodeFrom的getmembers方法
    nodeFrom instanceof AllTarfileOpens // 并且nodeFrom是AllTarfileOpens实例
    or
    // 处理`with closing(tarfile.open()) as file:`的情况，我们添加从`closing`的第一个参数到`closing`调用的步骤，
    // 只要第一个参数是`tarfile.open()`的返回值。
    nodeTo = API::moduleImport("contextlib").getMember("closing").getACall() and // 匹配contextlib模块中的closing调用
    nodeFrom = nodeTo.(API::CallNode).getArg(0) and // 获取closing的第一个参数
    nodeFrom = tarfileOpen().getReturn().getAValueReachableFromSource() // 确保第一个参数是tarfileOpen()的返回值
  }

  predicate observeDiffInformedIncrementalMode() { any() } // 观察差异信息增量模式
}

/** 全局污点跟踪以检测更多的“TarSlip”漏洞。 */
module TarSlipImprovFlow = TaintTracking::Global<TarSlipImprovConfig>;

from TarSlipImprovFlow::PathNode source, TarSlipImprovFlow::PathNode sink
where TarSlipImprovFlow::flowPath(source, sink) // 查找从源到接收器的污点传播路径
select sink, source, sink, "Extraction of tarfile from $@ to a potentially untrusted source $@.",
  source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString() // 选择接收器、源节点及其字符串表示形式，并生成警告消息
