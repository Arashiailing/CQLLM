/**
 * @name 归档文件解压中的任意文件访问（Zip Slip）
 * @description 检测不安全的归档解压操作，其中包含'..'的恶意路径可能逃逸目标目录，
 *              导致未授权的文件写入。
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python
import experimental.semmle.python.security.ZipSlip
import ZipSlipFlow::PathGraph

// 定义数据流路径的起点和终点节点
from ZipSlipFlow::PathNode entryNode, ZipSlipFlow::PathNode fileOpNode

// 追踪从归档条目到文件操作的危险数据流
where ZipSlipFlow::flowPath(entryNode, fileOpNode)

// 报告漏洞路径及上下文信息
select entryNode.getNode(), entryNode, fileOpNode,
  "此未净化的归档条目（可能包含'../'）到达了 $@。", fileOpNode.getNode(),
  "文件系统操作"