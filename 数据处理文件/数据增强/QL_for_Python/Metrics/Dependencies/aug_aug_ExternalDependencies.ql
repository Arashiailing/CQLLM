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
 * 此查询旨在分析Python代码中的外部包依赖情况，并提供以下信息：
 *
 * 1. 源文件标识 - 指向包含依赖关系的Python源文件
 * 2. 外部包标识 - 表示来自PyPI或其他外部仓库的包
 * 3. 版本详情 - 如果可用，包含包的版本信息
 * 4. 依赖频率 - 记录源文件中对外部包的引用次数
 *
 * 尽管查询结果只显示两列，但实际上包含了上述四类信息。
 * 这种设计是为了与现有仪表板数据库架构保持兼容。
 * 任何列数变更都需要相应调整仪表板数据库和提取器。
 *
 * 注意：文件路径前添加了'/'前缀，以匹配仪表板数据库中的相对路径格式。
 */

// 定义主查询逻辑：分析源文件与外部包的依赖关系并计算引用频率
from File sourceFile, int dependencyCount, string packageEntity, ExternalPackage externalPackage
where
  // 计算源文件中引用特定外部包的次数
  dependencyCount =
    strictcount(AstNode astNode |
      // 检查AST节点是否依赖于指定的外部包
      dependency(astNode, externalPackage) and
      // 确保节点属于我们正在分析的源文件
      astNode.getLocation().getFile() = sourceFile
    ) and
  // 创建一个复合标识符，结合源文件和包信息
  packageEntity = munge(sourceFile, externalPackage)
// 输出结果：按依赖计数降序排列的包实体和计数
select packageEntity, dependencyCount order by dependencyCount desc