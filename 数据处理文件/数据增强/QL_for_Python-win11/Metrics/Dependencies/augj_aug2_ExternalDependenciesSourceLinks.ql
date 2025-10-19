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
 * 本查询为 ExternalDependencies.ql 查询创建源链接。
 * 
 * 相关实体以 '/file/path<|>dependency' 的形式存在，
 * 其中 /file/path 是相对于源代码存档根目录的裸字符串，不与特定修订版绑定。
 * 我们需要 File 实体（此处的第二列）以便在进入仪表板数据库后，
 * 使用 ExternalEntity.getASourceLink() 方法恢复该信息。
 * 
 * 查询执行流程：
 * - 遍历所有源文件与外部包之间的依赖关系
 * - 为每个依赖关系生成唯一的实体标识符
 * - 返回实体标识符及其对应的源文件
 */

from File sourceFile, string depId
where
  exists(PackageObject externalPackage, AstNode refNode |
    // 确认存在从代码节点到外部包的引用关系
    dependency(refNode, externalPackage) and
    // 验证引用节点位于当前源文件中
    refNode.getLocation().getFile() = sourceFile and
    // 生成依赖实体标识符，组合源文件与包信息
    depId = munge(sourceFile, externalPackage)
  )
select depId, sourceFile