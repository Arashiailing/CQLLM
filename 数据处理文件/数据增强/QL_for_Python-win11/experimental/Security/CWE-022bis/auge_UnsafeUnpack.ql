/**
 * @name Arbitrary file write during a tarball extraction from a user controlled source
 * @description 提取来自用户控制源的tar文件时，未验证目标文件路径是否在目标目录内，可能导致目标目录外的文件被覆盖。
 *             更具体地说，如果tar文件来自用户控制的位置（无论是远程位置还是命令行参数），则可能发生这种情况。
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

// 定义恶意tarball源节点和不安全提取目标节点
from UnsafeUnpackFlow::PathNode maliciousTarballSource, 
     UnsafeUnpackFlow::PathNode unsafeExtractionSink
// 验证从恶意源到不安全目标的路径存在性
where UnsafeUnpackFlow::flowPath(maliciousTarballSource, unsafeExtractionSink)
// 生成安全警告，包含源节点、目标节点及风险描述
select unsafeExtractionSink.getNode(), 
       maliciousTarballSource, 
       unsafeExtractionSink,
       "Unsafe extraction from a malicious tarball retrieved from a remote location."