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
 * 相关实体的格式为'/file/path<|>dependency'，其中
 * /file/path是相对于源代码存档根目录的裸字符串，不与特定修订版关联。
 * 我们需要File实体（此处第二列）以便在进入仪表板数据库后，
 * 能够使用ExternalEntity.getASourceLink()方法恢复该信息。
 */

from File codeFile, string dependencyEntity
where
  exists(PackageObject pkg |
    exists(AstNode astNode |
      // 验证astNode与pkg之间存在依赖关系
      dependency(astNode, pkg) and
      // 确保astNode位于codeFile中
      astNode.getLocation().getFile() = codeFile
    ) and
    // 通过munge函数将codeFile和pkg组合成dependencyEntity
    dependencyEntity = munge(codeFile, pkg)
  )
select dependencyEntity, codeFile