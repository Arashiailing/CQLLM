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
 * 查询目标：为外部依赖生成源链接信息
 * 
 * 背景说明：
 * - 外部依赖实体表示为'/file/path<|>dependency'格式
 * - 路径部分是相对于源代码存档根目录的字符串
 * - 这些路径需要通过File实体建立版本关联
 * 
 * 功能描述：
 * - 识别代码文件与外部依赖之间的关系
 * - 生成仪表板数据库可用的源链接信息
 * - 输出中的File实体可通过ExternalEntity.getASourceLink()恢复源链接
 * 
 * 实现逻辑：
 * 1. 遍历所有Python代码文件
 * 2. 查找每个文件引用的外部包
 * 3. 为文件-包对生成依赖标识符
 * 4. 输出依赖标识符和源文件
 */

from File sourceFile, string packageIdentifier
where
  exists(PackageObject externalDependency, AstNode importNode |
    // 建立导入语句与外部依赖的关联
    dependency(importNode, externalDependency) and
    // 确保导入语句位于当前源文件中
    importNode.getLocation().getFile() = sourceFile and
    // 生成唯一的文件-依赖对标识符
    packageIdentifier = munge(sourceFile, externalDependency)
  )
select packageIdentifier, sourceFile