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
 * 本查询构建外部依赖关系的源链接映射。
 * 
 * 功能概述：
 * 此查询扫描代码库，识别所有源文件对外部包的引用关系，
 * 并为每个依赖关系创建唯一标识符，以便后续分析和跟踪。
 * 
 * 技术说明：
 * - 依赖实体格式：'/file/path<|>dependency'
 * - '/file/path'是相对于源代码存档根目录的路径
 * - 路径不绑定到特定版本，确保通用性
 * - File实体(输出第二列)用于仪表板数据库中的源链接获取
 *   通过ExternalEntity.getASourceLink()方法实现
 * 
 * 查询逻辑：
 * 1. 识别阶段：遍历所有源文件，查找对外部包的引用
 * 2. 验证阶段：确认引用节点位于当前分析的源文件中
 * 3. 标识阶段：为每个依赖关系生成唯一标识符
 * 4. 输出阶段：返回依赖标识符及其对应的源文件
 */

from File sourceFile, string dependencyIdentifier
where
  exists(PackageObject externalPackage, AstNode referenceNode |
    // 确认代码节点引用了外部包
    dependency(referenceNode, externalPackage) and
    
    // 验证引用节点位于当前源文件中
    referenceNode.getLocation().getFile() = sourceFile and
    
    // 生成依赖实体标识符，组合源文件与包信息
    dependencyIdentifier = munge(sourceFile, externalPackage)
  )
select dependencyIdentifier, sourceFile