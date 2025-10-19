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
 * 本查询用于识别代码库中的外部依赖关系并生成对应的源链接。
 * 输出格式为'/file/path<|>dependency'，其中'/file/path'表示
 * 相对于源代码根目录的文件路径（不关联特定版本）。
 * 查询结果中的File实体（第二列）可通过仪表板数据库中的
 * ExternalEntity.getASourceLink()方法重建源链接。
 */

from File targetFile, string dependencyLink
where
  exists(PackageObject importedPackage, AstNode nodeReference |
    // 检测代码节点是否引用了外部包
    dependency(nodeReference, importedPackage) and
    // 确认引用节点位于当前目标文件中
    nodeReference.getLocation().getFile() = targetFile and
    // 构建依赖源链接标识符
    dependencyLink = munge(targetFile, importedPackage)
  )
select dependencyLink, targetFile