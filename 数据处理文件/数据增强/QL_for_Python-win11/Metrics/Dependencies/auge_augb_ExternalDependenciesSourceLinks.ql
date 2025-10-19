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
 * 此查询旨在为ExternalDependencies.ql查询生成源链接信息。
 * 
 * 查询背景：
 * - 外部依赖实体通常表示为'/file/path<|>dependency'格式
 * - 其中的路径部分是相对于源代码存档根目录的简单字符串
 * - 这些路径不与特定代码版本关联，需要通过File实体建立版本关联
 * 
 * 查询目的：
 * - 识别代码文件与其引用的外部依赖之间的关系
 * - 生成可用于仪表板数据库的源链接信息
 * - 输出中的第二列（File实体）在进入仪表板数据库后，
 *   可通过ExternalEntity.getASourceLink()方法恢复源链接信息
 * 
 * 查询逻辑：
 * 1. 遍历所有Python代码文件
 * 2. 对于每个文件，查找其中引用的所有外部包
 * 3. 为每个文件-包对生成唯一的依赖标识符（格式为'/file/path<|>dependency'）
 * 4. 输出依赖标识符和对应的源文件
 */

from File sourceFile, string dependencyIdentifier
where
  exists(PackageObject packageObj, AstNode importNode |
    // 确认存在从当前文件中的导入节点到外部包的依赖关系
    dependency(importNode, packageObj) and
    // 验证导入节点确实位于我们正在处理的源文件中
    importNode.getLocation().getFile() = sourceFile and
    // 为源文件和依赖包生成唯一的依赖标识符
    dependencyIdentifier = munge(sourceFile, packageObj)
  )
select dependencyIdentifier, sourceFile