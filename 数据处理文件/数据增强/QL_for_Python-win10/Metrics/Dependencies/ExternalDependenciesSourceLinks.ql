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
 * 尽管相关实体的形式为'/file/path<|>dependency'，但
 * /file/path是相对于源代码存档根目录的裸字符串，不与特定修订版绑定。
 * 我们需要File实体（此处的第二列）来在进入仪表板数据库后使用
 * ExternalEntity.getASourceLink()方法恢复该信息。
 */

from File sourceFile, string entity
where
  exists(PackageObject package, AstNode src |
    // 检查是否存在从src到package的依赖关系
    dependency(src, package) and
    // 并且src的位置文件等于sourceFile
    src.getLocation().getFile() = sourceFile and
    // 将sourceFile和package进行munge操作得到entity
    entity = munge(sourceFile, package)
  )
select entity, sourceFile
