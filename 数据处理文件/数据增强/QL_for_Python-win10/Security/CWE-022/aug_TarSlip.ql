/**
 * @name Arbitrary file write during tarfile extraction
 * @description 当提取tar存档中的文件时，若未验证目标文件路径是否在目标目录范围内，
 *              可能导致目录遍历攻击，允许覆盖目标目录外的任意文件。
 * @kind path-problem
 * @id py/tarslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-022
 */

import python
import semmle.python.security.dataflow.TarSlipQuery
import TarSlipFlow::PathGraph

// 定义潜在不受信任的源节点和文件提取点
from TarSlipFlow::PathNode untrustedSource, TarSlipFlow::PathNode extractionPoint
// 检查是否存在从不受信任源到文件提取点的数据流路径
where TarSlipFlow::flowPath(untrustedSource, extractionPoint)
// 输出结果，包括提取点、不受信任源、提取点信息和警告消息
select extractionPoint.getNode(), untrustedSource, extractionPoint, 
  "This file extraction depends on a $@.", untrustedSource.getNode(),
  "potentially untrusted source"