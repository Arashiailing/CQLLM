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
 * 此查询旨在为ExternalDependencies.ql查询提供源链接生成功能。
 * 相关实体以'/file/path<|>dependency'格式表示，
 * 其中/file/path是相对于源代码存档根目录的简单路径字符串，不关联特定版本。
 * 我们需要File实体（即第二列）以便在数据进入仪表板数据库后，
 * 能够通过ExternalEntity.getASourceLink()方法检索该信息。
 */

from File sourceFile, string depEntity
where
  exists(PackageObject packageObj, AstNode node |
    // 验证依赖关系存在
    dependency(node, packageObj) and
    // 确保源节点位于当前处理的文件中
    node.getLocation().getFile() = sourceFile and
    // 构建依赖实体标识符
    depEntity = munge(sourceFile, packageObj)
  )
select depEntity, sourceFile