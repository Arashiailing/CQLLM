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
 * 本查询用于建立外部依赖关系的源链接映射。
 * 
 * 功能说明：依赖实体以'/file/path<|>dependency'格式表示，其中
 * /file/path是源代码存档根目录的相对路径，不绑定到特定版本。
 * 查询结果需要包含File实体(输出第二列)，以便在仪表板数据库中通过
 * ExternalEntity.getASourceLink()方法恢复源链接信息。
 * 
 * 算法逻辑：
 * 1. 识别所有引用外部包的代码节点
 * 2. 确定这些引用节点所在的源文件
 * 3. 为每个依赖关系生成唯一标识符
 * 4. 返回依赖标识符及其关联的源文件
 */

from File sourceFile, string dependencyIdentifier
where
  exists(PackageObject externalPackage, AstNode referenceNode |
    // 验证代码节点引用了外部包
    dependency(referenceNode, externalPackage) and
    
    // 确保引用节点位于当前源文件中
    referenceNode.getLocation().getFile() = sourceFile and
    
    // 生成依赖实体标识符，组合源文件与包信息
    dependencyIdentifier = munge(sourceFile, externalPackage)
  )
select dependencyIdentifier, sourceFile