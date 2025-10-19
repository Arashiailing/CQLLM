/**
 * @name Denial of Service using Unicode Characters
 * @description A remote user-controlled data can reach a costly Unicode normalization with either form NFKC or NFKD. On Windows OS, with an attack such as the One Million Unicode Characters, this could lead to a denial of service. And, with the use of special Unicode characters, like U+2100 (℀) or U+2105 (℅), the payload size could be tripled.
 * @kind path-problem
 * @id py/unicode-dos
 * @precision high
 * @problem.severity error
 * @tags security
 *       experimental
 *       external/cwe/cwe-770
 */

import python
import semmle.python.ApiGraphs
import semmle.python.Concepts
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.RemoteFlowSources

// 定义一个类，用于表示Unicode兼容性规范化调用。这些调用来自unicodedata、unidecode、pyunormalize和textnorm模块。
// argIdx用于约束被规范化的参数。
class UnicodeCompatibilityNormalize extends API::CallNode {
  int argIdx; // 参数索引

  UnicodeCompatibilityNormalize() {
    (
      this = API::moduleImport("unicodedata").getMember("normalize").getACall() and
      this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
          "NFKC", "NFKD"
        ]
      or
      this = API::moduleImport("pyunormalize").getMember("normalize").getACall() and
      this.getParameter(0).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
          "NFKC", "NFKD"
        ]
    ) and
    argIdx = 1 // 如果匹配到上述情况，则设置argIdx为1
    or
    (
      this = API::moduleImport("textnorm").getMember("normalize_unicode").getACall() and
      this.getParameter(1).getAValueReachingSink().asExpr().(StringLiteral).getText() in [
          "NFKC", "NFKD"
        ]
      or
      this = API::moduleImport("unidecode").getMember("unidecode").getACall()
      or
      this = API::moduleImport("pyunormalize").getMember(["NFKC", "NFKD"]).getACall()
    ) and
    argIdx = 0 // 如果匹配到上述情况，则设置argIdx为0
  }

  DataFlow::Node getPathArg() { result = this.getArg(argIdx) } // 获取路径参数节点
}

// 定义一个谓词，用于检查在特定条件下是否满足值限制条件。
predicate underAValue(DataFlow::GuardNode g, ControlFlowNode node, boolean branch) {
  exists(CompareNode cn | cn = g |
    exists(API::CallNode lenCall, Cmpop op, Node n |
      lenCall = n.getALocalSource() and
      (
        // arg <= LIMIT OR arg < LIMIT
        (op instanceof LtE or op instanceof Lt) and
        branch = true and
        cn.operands(n.asCfgNode(), op, _)
        or
        // LIMIT >= arg OR LIMIT > arg
        (op instanceof GtE or op instanceof Gt) and
        branch = true and
        cn.operands(_, op, n.asCfgNode())
        or
        // not arg >= LIMIT OR not arg > LIMIT
        (op instanceof GtE or op instanceof Gt) and
        branch = false and
        cn.operands(n.asCfgNode(), op, _)
        or
        // not LIMIT <= arg OR not LIMIT < arg
        (op instanceof LtE or op instanceof Lt) and
        branch = false and
        cn.operands(_, op, n.asCfgNode())
      )
    |
      lenCall = API::builtin("len").getACall() and
      node = lenCall.getArg(0).asCfgNode() // 确保是内置函数len的调用，并获取其第一个参数节点
    ) //and
    //not cn.getLocation().getFile().inStdlib() // 注释掉的标准库检查
  )
}

// 定义一个私有模块，配置数据流分析的相关规则。
private module UnicodeDoSConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource } // 定义源节点为远程流源

  predicate isBarrier(DataFlow::Node sanitizer) {
    // underAValue是一个检查，确保用户提供的值的长度限制在一定范围内。
    sanitizer = DataFlow::BarrierGuard<underAValue/3>::getABarrierNode() // 定义屏障节点为underAValue检查节点
  }

  predicate isSink(DataFlow::Node sink) {
    // 任何对Unicode兼容性规范化的调用都是一个高成本操作。
    sink = any(UnicodeCompatibilityNormalize ucn).getPathArg()
    or
    // pallets/werkzeug中的secure_filename()调用在底层使用Unicode兼容性规范化。
    sink = API::moduleImport("werkzeug").getMember("secure_filename").getACall().getArg(_)
    or
    sink =
      API::moduleImport("werkzeug")
          .getMember("utils")
          .getMember("secure_filename")
          .getACall()
          .getArg(_) // 定义接收节点为Unicode兼容性规范化调用或secure_filename调用的参数节点
  }

  predicate observeDiffInformedIncrementalMode() { any() } // 增量模式观察差异的谓词，这里不做具体实现
}

// 定义全局数据流分析模块，使用UnicodeDoSConfig配置。
module UnicodeDoSFlow = TaintTracking::Global<UnicodeDoSConfig>;

import UnicodeDoSFlow::PathGraph // 导入路径图模块

from UnicodeDoSFlow::PathNode source, UnicodeDoSFlow::PathNode sink // 从源节点和接收节点中选择路径
where UnicodeDoSFlow::flowPath(source, sink) // 条件：存在从源节点到接收节点的数据流路径
select sink.getNode(), source, sink, "This $@ can reach a $@.", source.getNode(),
  "user-provided value", sink.getNode(), "costly Unicode normalization operation" // 选择结果并生成报告信息
