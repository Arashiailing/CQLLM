/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/hashers
 * @tags external/cwe/cwe-200
 */

// 导入Python库，用于分析Python代码
import python

// 导入用于检测弱敏感数据哈希的库
import semmle.python.security.HasherVerification

// 定义查询谓词，查找不安全的哈希器使用情况
query predicate problems = HasherVerifier::usesUnsafeHasher/2;