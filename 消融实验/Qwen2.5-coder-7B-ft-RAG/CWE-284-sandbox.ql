/**
 * @name CWE-284: Improper Access Control
 * @description A file has been opened with unsafe permissions, which may give too much access to other users.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision medium
 * @id py/file-open-with-unsafe-permissions
 * @tags security
 *       external/cwe/cwe-284
 */

// 导入用于文件系统权限检查的库
private import semmle.python.security.dataflow.FilePermissionQuery

// 定义查询谓词，查找具有不安全权限的文件打开操作
query predicate problems = FilePermissionFlow::fileOpenWithInsecurePermissions();