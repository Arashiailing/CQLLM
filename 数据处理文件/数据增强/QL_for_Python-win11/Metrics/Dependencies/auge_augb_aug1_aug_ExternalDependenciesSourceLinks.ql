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
 * 此查询旨在检测Python项目中的外部依赖关系，并生成相应的源链接数据。
 * 输出结果采用'/file/path<|>dependency'格式，其中:
 * - '/file/path' 表示相对于源代码存档根目录的文件路径
 * - 该路径不与特定的代码版本绑定
 * 查询结果中的File实体(第二列)可通过仪表板数据库中的
 * ExternalEntity.getASourceLink()方法用于恢复源链接。
 */

from File codeFile, string sourceLink
where
  exists(PackageObject importedPackage, AstNode referencingNode |
    // 验证代码节点是否引用了外部包
    dependency(referencingNode, importedPackage) and
    // 确认引用节点位于当前分析的源文件范围内
    referencingNode.getLocation().getFile() = codeFile and
    // 生成标准化的依赖源链接字符串
    sourceLink = munge(codeFile, importedPackage)
  )
select sourceLink, codeFile