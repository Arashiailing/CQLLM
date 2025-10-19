/**
 * @deprecated
 * @name 外部依赖源链接
 * @kind source-link
 * @metricType externalDependency
 * @id py/dependency-source-links
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 本查询为ExternalDependencies.ql查询创建源链接。
 * 尽管相关实体的形式为'/file/path<|>dependency'，但
 * /file/path是相对于源代码存档根目录的裸字符串，不与特定修订版绑定。
 * 我们需要File实体（此处的第二列）来在进入仪表板数据库后使用
 * ExternalEntity.getASourceLink()方法恢复该信息。
 * 
 * 查询逻辑说明：
 * - 遍历所有源文件与外部包之间的依赖关系
 * - 为每个依赖关系生成唯一实体标识符
 * - 返回实体标识符及其对应的源文件
 */

from File sourceArchiveFile, string dependencyIdentifier
where
  exists(PackageObject importedPackage, AstNode referencingNode |
    // 确认存在从代码节点到外部包的引用关系
    dependency(referencingNode, importedPackage) and
    // 验证引用节点位于当前源文件中
    referencingNode.getLocation().getFile() = sourceArchiveFile and
    // 生成依赖实体标识符，组合源文件与包信息
    dependencyIdentifier = munge(sourceArchiveFile, importedPackage)
  )
select dependencyIdentifier, sourceArchiveFile