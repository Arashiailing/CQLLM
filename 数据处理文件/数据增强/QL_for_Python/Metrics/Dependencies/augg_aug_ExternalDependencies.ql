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
 * 此查询分析Python项目中的外部依赖关系，并生成以下信息：
 *
 * - 源文件路径：标识依赖关系的来源文件（路径前添加'/'以确保与仪表板数据库格式一致）
 * - 外部包对象：指PyPI或其他外部仓库提供的包
 * - 包版本信息：如果能够获取到的话
 * - 依赖计数：源文件中引用该包的次数
 *
 * 查询结果以两列形式呈现，这是为了兼容现有的仪表板数据库架构。
 * 如需返回更多列，需要相应修改仪表板数据库架构和提取器。
 */

// 主查询：识别源文件与外部包之间的依赖关系并统计引用次数
from File sourceFile, int dependencyCount, string dependencyIdentifier, ExternalPackage thirdPartyPackage
where
  // 计算特定源文件对特定外部包的依赖数量
  dependencyCount =
    strictcount(AstNode astNode |
      dependency(astNode, thirdPartyPackage) and // 检查AST节点是否依赖于指定的外部包
      astNode.getLocation().getFile() = sourceFile // 确保节点位于指定的源文件中
    ) and
  // 将源文件和包信息合并为单一实体标识符
  dependencyIdentifier = munge(sourceFile, thirdPartyPackage)
// 输出结果：实体标识符和依赖计数，按依赖数量降序排列
select dependencyIdentifier, dependencyCount order by dependencyCount desc