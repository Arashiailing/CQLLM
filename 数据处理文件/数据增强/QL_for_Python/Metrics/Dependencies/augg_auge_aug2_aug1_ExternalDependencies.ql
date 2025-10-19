/**
 * @deprecated
 * @name 外部依赖关系
 * @description 计算一个Python源文件对外部包的依赖数量。
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 本查询用于分析Python源文件与外部包之间的依赖关系，量化每个文件对外部包的依赖程度。
 * 
 * 查询核心要素：
 * - 源代码文件路径（依赖关系主体）
 * - 外部包对象（PyPI或类似外部源提供的包）
 * - 包版本信息（如果可用）
 * - 源文件对该包的依赖数量统计
 * 
 * 输出格式：
 * - 第一列：依赖实体标识符（文件路径和外部包的组合）
 * - 第二列：依赖计数
 * 
 * 注意：文件路径前添加'/'前缀，以与仪表板数据库中的相对文件路径格式保持一致。
 */

// 定义查询变量：源文件、外部包、依赖计数和依赖实体
from File codeFile, ExternalPackage externalPkg, int dependencyCount, string dependencyId
where
  // 计算源文件对特定外部包的依赖数量
  dependencyCount =
    strictcount(AstNode syntaxNode |
      // 检查AST节点是否依赖于指定的外部包
      dependency(syntaxNode, externalPkg) and
      // 确保AST节点位于指定的源文件中
      syntaxNode.getLocation().getFile() = codeFile
    ) and
  // 将源文件和外部包信息合并为单个实体标识符
  dependencyId = munge(codeFile, externalPkg)
// 输出结果：依赖实体和依赖计数，按依赖数量降序排列
select dependencyId, dependencyCount order by dependencyCount desc