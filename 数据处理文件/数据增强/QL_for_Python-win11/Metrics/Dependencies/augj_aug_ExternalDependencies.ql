/**
 * @deprecated
 * @name 外部依赖关系
 * @description 统计Python源文件中引用的外部包依赖数量
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 此查询分析Python源文件中的外部依赖关系，并提供以下关键信息：
 *
 * 输出格式说明：
 * - 第一列：组合实体标识符，包含源文件路径和外部包名称
 * - 第二列：依赖计数，表示源文件中引用该外部包的次数
 *
 * 尽管查询实际编码了四个逻辑信息（源文件路径、外部包对象、包版本信息、依赖计数），
 * 但为了与现有仪表板数据库架构兼容，仅返回两列数据。
 *
 * 实现细节：
 * - 文件路径前添加'/'前缀，确保与仪表板数据库中的相对路径格式一致
 * - 结果按依赖数量降序排列，便于识别高频依赖
 */

// 主查询逻辑：识别源文件与外部包之间的依赖关系并统计引用次数
from File sourceFile, int dependencyCount, string packageEntity, ExternalPackage externalPackage
where
  // 计算特定源文件对特定外部包的依赖数量
  dependencyCount =
    strictcount(AstNode astNode |
      // 检查AST节点是否依赖于指定的外部包
      dependency(astNode, externalPackage) and
      // 确保节点位于指定的源文件中
      astNode.getLocation().getFile() = sourceFile
    ) and
  // 将源文件和包信息合并为单一实体标识符，用于结果展示
  packageEntity = munge(sourceFile, externalPackage)
// 输出结果：实体标识符和依赖计数，按依赖数量降序排列
select packageEntity, dependencyCount order by dependencyCount desc