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
 * 本查询用于为ExternalDependencies.ql查询生成源链接。
 * 虽然相关实体呈现为'/file/path<|>dependency'格式，
 * 但/file/path是相对于源代码存档根目录的简单字符串，不与特定版本关联。
 * 我们需要File实体（即第二列）以便在进入仪表板数据库后，
 * 能够通过ExternalEntity.getASourceLink()方法恢复该信息。
 */

from File codeFile, string dependencyEntity
where
  exists(PackageObject pkg, AstNode sourceNode |
    // 验证依赖关系存在
    dependency(sourceNode, pkg) and
    // 确保源节点位于当前处理的文件中
    sourceNode.getLocation().getFile() = codeFile and
    // 构建依赖实体标识符
    dependencyEntity = munge(codeFile, pkg)
  )
select dependencyEntity, codeFile