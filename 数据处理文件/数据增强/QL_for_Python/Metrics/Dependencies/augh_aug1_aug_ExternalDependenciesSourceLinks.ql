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
 * 此查询用于创建外部依赖的源链接信息。
 * 输出结果遵循'/file/path<|>dependency'格式，其中
 * '/file/path'是相对于源代码存档根目录的文件路径，
 * 该路径不与特定代码版本绑定。查询结果中的File实体
 * （第二列）用于在仪表板数据库中通过
 * ExternalEntity.getASourceLink()方法恢复源链接。
 */

from File codeFile, string depSourceLink
where
  exists(PackageObject externalPkg, AstNode node |
    // 验证节点与外部包的依赖关系
    dependency(node, externalPkg) and
    // 确认节点所属文件与当前代码文件一致
    node.getLocation().getFile() = codeFile and
    // 生成依赖源链接字符串
    depSourceLink = munge(codeFile, externalPkg)
  )
select depSourceLink, codeFile