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
 * 查询结果编码了以下信息：
 *
 * 1. Python源文件路径（相对于源存档位置）
 * 2. 外部包对象（通常是PyPI或类似的外部提供的包）
 * 3. 包版本信息（如果可用）
 * 4. 源文件对该包的依赖数量
 *
 * 注意：由于仪表板数据库架构的限制，查询结果被编码为两列。
 * 理想情况下，应该返回三列以提供更清晰的数据结构。
 * 文件路径前添加了'/'前缀，以匹配仪表板数据库中使用的相对路径格式。
 */

// 定义谓词函数，用于计算特定源文件对特定外部包的依赖数量
predicate calculateExternalDependencies(File sourceFile, ExternalPackage externalPkg, int dependencyCount) {
  // 统计源文件中所有依赖于指定外部包的AST节点数量
  dependencyCount =
    strictcount(AstNode node |
      dependency(node, externalPkg) and // 检查节点是否依赖于指定的外部包
      node.getLocation().getFile() = sourceFile // 确保节点位于指定的源文件中
    )
}

// 查询主逻辑：获取文件、依赖数量、编码实体和外部包信息
from File sourceFile, int dependencyCount, string encodedEntity, ExternalPackage externalPkg
where
  // 确保源文件对指定外部包存在依赖关系
  calculateExternalDependencies(sourceFile, externalPkg, dependencyCount) and
  // 对源文件和外部包信息进行编码，生成实体标识符
  encodedEntity = munge(sourceFile, externalPkg)
// 返回编码实体和依赖数量，并按依赖数量降序排列
select encodedEntity, dependencyCount order by dependencyCount desc