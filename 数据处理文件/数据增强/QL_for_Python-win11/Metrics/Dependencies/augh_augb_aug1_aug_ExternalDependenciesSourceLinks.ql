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
 * 本查询用于识别Python项目中的外部依赖并生成相应的源链接信息。
 * 输出实体遵循'/file/path<|>dependency'格式，其中:
 * - '/file/path' 表示相对于源代码存档根目录的文件路径
 * - 该路径不绑定到特定的代码版本
 * 查询结果中的File实体(第二列)可通过仪表板数据库中的
 * ExternalEntity.getASourceLink()方法用于恢复源链接。
 */

from File filePath, string dependencySourceLink
where
  exists(PackageObject externalPkg, AstNode referencingNode |
    // 检查代码节点是否引用了外部包
    dependency(referencingNode, externalPkg) and
    // 确保引用节点位于当前分析的源文件内
    referencingNode.getLocation().getFile() = filePath and
    // 构建标准化的依赖源链接字符串
    dependencySourceLink = munge(filePath, externalPkg)
  )
select dependencySourceLink, filePath