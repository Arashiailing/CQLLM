/**
 * @name CWE-264: Command Injection
 * @description nan
 * @kind path-problem
 * @id py/kvs
 * @problem.severity error
 * @precision high
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 */

import python
import semmle.python.ApiGraphs

// 定义一个辅助函数，用于确定节点是否属于受信任的命令构造位置
predicate trusted_command_construction(AstNode node, string description) {
  // 情况1：调用subprocess.Popen方法的调用节点，该方法用于启动新进程
  (
    exists(API::Call call |
      call = node.asCfgNode() and
      call.getFunc().(Attribute).getName() = "Popen" and
      call.getAnArg().(ImmutableLiteral).asString() = "/bin/sh"
    )
    and
    description = "subprocess.Popen"
  )
  or
  // 情况2：调用os.system方法的调用节点，该方法用于执行系统命令
  (
    exists(API::Call call |
      call = node.asCfgNode() and
      call.getFunc().(Name).getId() = "system"
    )
    and
    description = "os.system"
  )
}

// 定义一个辅助函数，用于确定节点是否位于可信命令构造位置
predicate at_trusted_command_construction(CallNode node, string description) {
  // 如果节点本身是可信命令构造位置，则返回True
  trusted_command_construction(node.getNode(), description)
  or
  // 或者，如果节点的下一个语句是一个可信命令构造位置，则返回True
  exists(Stmt next_stmt | next_stmt = node.getNextStmt() |
    trusted_command_construction(next_stmt, description)
  )
}

// 主查询部分：
// 选择任意两个节点n1和n2，使得存在从n1到n2的流动路径
from Node n1, Node n2
where CodeInjectionFlow::flowPath(n1, n2)
select n2.getNode(), n1, n2,
  // 生成警告信息，格式为：“This command injection depends on a $@.”加上n1的信息
  "This command injection depends on a $@.",
  n1.getNode(), "user-provided value"