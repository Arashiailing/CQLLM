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
 * 本查询旨在为外部依赖生成源链接信息。
 * 生成的实体采用'/file/path<|>dependency'格式，其中
 * '/file/path'表示相对于源代码存档根目录的文件路径，
 * 该路径不与特定代码版本关联。查询输出中的File实体
 * （第二列）用于在仪表板数据库中通过
 * ExternalEntity.getASourceLink()方法恢复源链接。
 */

from File sourceFile, string dependencySourceLink
where
  exists(PackageObject externalDependency, AstNode codeNode |
    // 检查代码节点与外部依赖之间是否存在依赖关系
    dependency(codeNode, externalDependency) and
    // 确保代码节点所属文件与源文件匹配
    codeNode.getLocation().getFile() = sourceFile and
    // 构建依赖源链接字符串
    dependencySourceLink = munge(sourceFile, externalDependency)
  )
select dependencySourceLink, sourceFile