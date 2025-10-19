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
 * 此查询为ExternalDependencies.ql查询创建源链接。
 * 相关实体的格式为'/file/path<|>dependency'，其中
 * /file/path是相对于源代码存档根目录的路径字符串，
 * 不与特定修订版绑定。我们需要File实体（输出中的第二列）
 * 以便在进入仪表板数据库后能够使用
 * ExternalEntity.getASourceLink()方法恢复源链接信息。
 */

from File archiveFile, string dependencyEntity
where
  exists(PackageObject externalPackage, AstNode astOrigin |
    // 验证存在从astOrigin到externalPackage的依赖关系
    dependency(astOrigin, externalPackage) and
    // 确认astOrigin的位置文件与archiveFile相同
    astOrigin.getLocation().getFile() = archiveFile and
    // 通过munge函数将archiveFile和externalPackage组合生成dependencyEntity
    dependencyEntity = munge(archiveFile, externalPackage)
  )
select dependencyEntity, archiveFile