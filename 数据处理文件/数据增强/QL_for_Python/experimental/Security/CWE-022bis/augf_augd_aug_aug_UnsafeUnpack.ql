/**
 * @name Arbitrary file write during tarball extraction from untrusted source
 * @description 当解压来自用户控制的tar文件时，若未验证目标路径是否在目标目录内，
 *             攻击者可能利用目录遍历漏洞写入任意文件。此漏洞常见于tar文件源自不受信任位置
 *             （如远程服务器或用户输入参数）的场景。
 * @kind path-problem
 * @id py/unsafe-unpacking
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python
import experimental.Security.UnsafeUnpackQuery
import UnsafeUnpackFlow::PathGraph

// 识别从不可信源到危险解包操作的数据流路径
from UnsafeUnpackFlow::PathNode untrustedSource, 
     UnsafeUnpackFlow::PathNode vulnerableExtraction
where 
  // 确保存在从不可信源到危险解包操作的数据流
  UnsafeUnpackFlow::flowPath(untrustedSource, vulnerableExtraction)
select vulnerableExtraction.getNode(), 
       untrustedSource, 
       vulnerableExtraction,
       "此解包操作存在漏洞：从不受信任来源获取的恶意tar文件可能导致目录遍历攻击"