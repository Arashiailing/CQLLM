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

// 导入Python库，用于分析Python代码
import python

// 导入实验性的安全分析库，用于检测ZipSlip漏洞
import experimental.semmle.python.security.ZipSlip

// 导入路径图类，用于表示文件路径的流动
import ZipSlipFlow::PathGraph

// 从路径图中选择源节点和目标节点
from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink

// 条件：如果存在从源节点到目标节点的路径流动
where ZipSlipFlow::flowPath(source, sink)

// 选择源节点、目标节点以及相关信息进行输出
select source.getNode(), source, sink,
  "This unsanitized archive entry, which may contain '..', is used in a $@.", sink.getNode(),
  "file system operation"
