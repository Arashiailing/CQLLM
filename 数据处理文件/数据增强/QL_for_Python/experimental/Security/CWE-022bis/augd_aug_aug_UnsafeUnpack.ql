/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 在解压用户控制的tar文件时，若未验证目标路径是否在目标目录内，
 *             可能导致目录遍历攻击。此漏洞常见于tar文件源自不受信任位置
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

// 检测从用户控制源到危险解包操作的数据流路径
from UnsafeUnpackFlow::PathNode userControlledSource, 
     UnsafeUnpackFlow::PathNode unsafeExtractionSink
where UnsafeUnpackFlow::flowPath(userControlledSource, unsafeExtractionSink)
select unsafeExtractionSink.getNode(), 
       userControlledSource, 
       unsafeExtractionSink,
       "危险解包操作：从不信任的远程位置获取的恶意tar文件可能导致目录遍历攻击"