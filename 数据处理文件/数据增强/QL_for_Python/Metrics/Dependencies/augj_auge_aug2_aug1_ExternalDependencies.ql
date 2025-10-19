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
 * 本查询用于分析Python源文件与外部包之间的依赖关系，并量化每个文件对外部包的依赖程度。
 * 
 * 查询核心要素：
 * - 源代码文件路径（作为依赖关系的主体）
 * - 外部包对象（来自PyPI或类似外部源的包）
 * - 包版本信息（在可用的情况下）
 * - 源文件对该包的依赖数量统计
 * 
 * 输出格式：
 * - 第一列：依赖实体标识符（由文件路径和外部包信息组合而成）
 * - 第二列：依赖计数
 * 
 * 注意：文件路径前会添加'/'前缀，以确保与仪表板数据库中的相对文件路径格式保持一致。
 */

// 定义查询变量：源文件、依赖计数、依赖实体和外部包
from File codeFile, int dependencyCount, string dependencyEntity, ExternalPackage externalPkg
where
  // 计算指定源文件对特定外部包的依赖数量
  dependencyCount =
    strictcount(AstNode node |
      // 验证AST节点是否依赖于指定的外部包
      dependency(node, externalPkg) and
      // 确认AST节点位于指定的源文件中
      node.getLocation().getFile() = codeFile
    ) and
  // 将源文件和外部包信息合并为统一的实体标识符
  dependencyEntity = munge(codeFile, externalPkg)
// 输出结果：依赖实体和依赖计数，按依赖数量降序排列
select dependencyEntity, dependencyCount order by dependencyCount desc