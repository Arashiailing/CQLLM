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
 * 背景说明：依赖实体表示为'/file/path<|>dependency'格式，其中
 * /file/path是源代码存档根目录的相对路径，不绑定到特定版本。
 * 我们需要File实体(输出第二列)以便在仪表板数据库中通过
 * ExternalEntity.getASourceLink()方法获取源链接信息。
 * 
 * 查询执行流程：
 * - 识别所有源文件对外部包的引用
 * - 为每个依赖关系创建唯一标识符
 * - 返回依赖标识符及其对应的源文件
 */

from File originFile, string dependencyId
where
  exists(PackageObject extPackage, AstNode refNode |
    // 第一阶段：确认代码节点引用了外部包
    dependency(refNode, extPackage) and
    
    // 第二阶段：验证引用节点位于当前源文件中
    refNode.getLocation().getFile() = originFile and
    
    // 第三阶段：生成依赖实体标识符，组合源文件与包信息
    dependencyId = munge(originFile, extPackage)
  )
select dependencyId, originFile