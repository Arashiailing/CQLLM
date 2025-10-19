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
 * 本查询为Python项目中的外部依赖项创建源链接。
 * 输出实体格式为'/file/path<|>dependency'，其中
 * /file/path是相对于源代码存档根目录的文件路径，
 * 不与特定代码版本绑定。我们需要File实体（输出中的第二列）
 * 以便在导入仪表板数据库后，能够使用
 * ExternalEntity.getASourceLink()方法重新获取源链接信息。
 */

from File sourceArchiveFile, string externalDependencyEntity
where
  exists(PackageObject importedPackage, AstNode codeNodeOrigin |
    // 验证代码节点和外部包之间的依赖关系
    dependency(codeNodeOrigin, importedPackage) and
    // 确保代码节点位于当前处理的存档文件中
    codeNodeOrigin.getLocation().getFile() = sourceArchiveFile and
    // 生成包含文件路径和依赖信息的实体字符串
    externalDependencyEntity = munge(sourceArchiveFile, importedPackage)
  )
select externalDependencyEntity, sourceArchiveFile