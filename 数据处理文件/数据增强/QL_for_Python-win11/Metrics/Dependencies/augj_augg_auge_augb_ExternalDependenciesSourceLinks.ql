/**
 * @deprecated
 * @name 外部依赖源链接
 * @kind source-link
 * @metricType externalDependency
 * @id py/dependency-source-links
 */

import python
import semmle.python.dependencies.TechInventory

/**
 * 查询目标：为项目中的外部依赖项生成源链接映射
 * 
 * 背景说明：
 * - 外部依赖项表示为'/relative/path<|>package_name'格式的标识符
 * - 路径部分表示相对于源代码根目录的文件位置
 * - 通过File实体可以建立与特定版本的关联关系
 * 
 * 功能描述：
 * - 分析Python源文件与外部包之间的引用关系
 * - 生成可用于仪表板数据库的源链接映射数据
 * - 结果中的File实体可通过ExternalEntity.getASourceLink()方法获取源链接
 * 
 * 实现步骤：
 * 1. 遍历所有Python源文件
 * 2. 识别每个文件中导入的外部包
 * 3. 为每个文件-包对创建唯一依赖标识符
 * 4. 输出依赖标识符及其对应的源文件
 */

from File sourceFile, string pkgIdentifier
where
  exists(PackageObject importedPkg, AstNode importNode |
    // 检查导入节点是否引用了外部包
    dependency(importNode, importedPkg) and
    // 确保导入节点位于当前分析的源文件中
    importNode.getLocation().getFile() = sourceFile and
    // 基于源文件和导入包生成唯一标识符
    pkgIdentifier = munge(sourceFile, importedPkg)
  )
select pkgIdentifier, sourceFile