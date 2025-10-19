/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Extracting files from a malicious ZIP file, or similar type of archive, without
 *              validating that the destination file path is within the destination directory
 *              can allow an attacker to unexpectedly gain access to resources.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

// 导入Python分析库
import python

// 导入ZipSlip漏洞检测的实验性安全分析库
import experimental.semmle.python.security.ZipSlip

// 导入路径图类，用于建模文件路径流动
import ZipSlipFlow::PathGraph

// 定义归档条目节点和文件操作节点
from ZipSlipFlow::PathNode entryNode, ZipSlipFlow::PathNode operationNode

// 验证是否存在从归档条目到文件操作的路径流动
where ZipSlipFlow::flowPath(entryNode, operationNode)

// 输出漏洞路径及相关描述
select entryNode.getNode(), entryNode, operationNode,
  "This unsanitized archive entry, which may contain '..', is used in a $@.", operationNode.getNode(),
  "file system operation"