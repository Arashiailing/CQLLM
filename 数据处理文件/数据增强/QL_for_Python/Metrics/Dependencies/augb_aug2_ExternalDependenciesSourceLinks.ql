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
 * 此查询为外部依赖关系创建源链接映射。
 * 
 * 背景：依赖实体表示为'/file/path<|>dependency'格式，其中
 * /file/path是源代码存档根目录的相对路径，未绑定到特定版本。
 * 我们需要File实体(输出第二列)以便在仪表板数据库中通过
 * ExternalEntity.getASourceLink()方法恢复源链接信息。
 * 
 * 查询逻辑概述：
 * - 遍历所有源文件与外部包之间的引用关系
 * - 为每个依赖关系生成唯一标识符
 * - 返回依赖标识符及其关联的源文件
 */

from File srcFile, string depId
where
  exists(PackageObject pkg, AstNode refNode |
    // 步骤1: 确认代码节点引用了外部包
    dependency(refNode, pkg) and
    
    // 步骤2: 验证引用节点位于当前源文件中
    refNode.getLocation().getFile() = srcFile and
    
    // 步骤3: 生成依赖实体标识符，组合源文件与包信息
    depId = munge(srcFile, pkg)
  )
select depId, srcFile