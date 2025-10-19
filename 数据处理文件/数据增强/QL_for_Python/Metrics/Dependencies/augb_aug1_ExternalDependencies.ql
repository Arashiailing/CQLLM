/**
 * @deprecated
 * @name 外部依赖关系
 * @description 量化Python源文件所依赖的外部包数量。
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 本查询输出两列数据，但实际涵盖了四个方面的信息：
 *
 * 1. Python源文件的路径（作为依赖关系的主体）
 * 2. 外部包对象（通常指PyPI或其他外部源提供的包）
 * 3. 包的版本信息（如果可获取）
 * 4. 源文件对该特定包的依赖数量
 *
 * 理想情况下，查询应当输出三列数据，
 * 但这需要调整仪表板数据库架构和数据提取器。
 *
 * 文件路径添加了'/'前缀，
 * 以匹配仪表板数据库中使用的相对文件路径格式。
 */

// 从Python文件、外部包、依赖计数和依赖实体中选择数据
from File pythonFile, ExternalPackage extPackage, int dependencyCount, string dependencyEntity
where
  // 计算Python文件对外部包的依赖数量
  dependencyCount =
    strictcount(AstNode node |
      dependency(node, extPackage) and // 检查AST节点是否依赖于指定的外部包
      node.getLocation().getFile() = pythonFile // 确保AST节点位于指定的源文件中
    ) and
  // 将Python文件和外部包信息合并为单个实体标识符
  dependencyEntity = munge(pythonFile, extPackage)
// 选择依赖实体和依赖计数，并按依赖数量降序排列
select dependencyEntity, dependencyCount order by dependencyCount desc