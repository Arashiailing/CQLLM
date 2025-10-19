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
 * 本查询用于识别Python项目中的外部依赖关系，并生成相应的源链接数据。
 * 
 * 输出格式为：'/file/path<|>dependency'
 * 其中：
 * - '/file/path'：相对于源代码存档根目录的文件路径，不绑定特定代码版本
 * - 'dependency'：被引用的外部依赖包名称
 * 
 * 查询结果中的File实体（第二列）可通过仪表板数据库中的
 * ExternalEntity.getASourceLink()方法用于恢复源链接。
 */

from File sourceFile, string dependencySourceLink
where
  exists(PackageObject externalPackage, AstNode importNode |
    // 检查是否存在从导入节点到外部包的依赖关系
    dependency(importNode, externalPackage) and
    
    // 确保导入节点位于当前分析的源文件中
    importNode.getLocation().getFile() = sourceFile and
    
    // 生成标准化的依赖源链接字符串
    dependencySourceLink = munge(sourceFile, externalPackage)
  )
select dependencySourceLink, sourceFile