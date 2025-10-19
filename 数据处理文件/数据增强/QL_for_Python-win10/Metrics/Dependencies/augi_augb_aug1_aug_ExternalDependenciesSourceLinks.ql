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
 * 此查询用于检测Python项目中的外部依赖项，并生成对应的源链接信息。
 * 输出格式为'/file/path<|>dependency'，其中:
 * - '/file/path' 是相对于源代码存档根目录的文件路径
 * - 路径信息不与特定代码版本绑定
 * 查询结果中的File实体(第二列)可通过仪表板数据库中的
 * ExternalEntity.getASourceLink()方法用于恢复源链接。
 */

from File codeFile, string externalDependencyLink
where
  exists(PackageObject importedPackage, AstNode referenceNode |
    // 验证引用节点确实引用了一个外部包
    dependency(referenceNode, importedPackage) and
    // 确认引用节点位于当前分析的源代码文件内
    referenceNode.getLocation().getFile() = codeFile and
    // 生成标准化的外部依赖源链接字符串
    externalDependencyLink = munge(codeFile, importedPackage)
  )
select externalDependencyLink, codeFile