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
 * 此查询返回两列数据，但实际编码了四个逻辑信息：
 *
 * 1. Python源文件路径（作为依赖关系的来源）
 * 2. 外部包对象（通常指PyPI或类似外部源提供的包）
 * 3. 包的版本信息（如果可用）
 * 4. 源文件对该包的依赖数量
 *
 * 理想情况下，查询应返回三列数据，
 * 但这需要对仪表板数据库架构和提取器进行修改。
 *
 * 文件路径前添加了'/'前缀，
 * 以与仪表板数据库中使用的相对文件路径格式保持一致。
 */

// 计算特定源文件对特定外部包的依赖数量
predicate src_package_count(File sourceFile, ExternalPackage package, int total) {
  total =
    strictcount(AstNode astNode |
      dependency(astNode, package) and // 检查AST节点是否依赖于指定的外部包
      astNode.getLocation().getFile() = sourceFile // 确保AST节点位于指定的源文件中
    )
}

// 从Python源文件、外部包、依赖计数和依赖实体中选择数据
from File sourceFile, int total, string entity, ExternalPackage package
where
  // 使用谓词函数计算源文件对外部包的依赖数量
  src_package_count(sourceFile, package, total) and
  // 将源文件和外部包信息合并为单个实体标识符
  entity = munge(sourceFile, package)
// 选择依赖实体和依赖计数，并按依赖数量降序排列
select entity, total order by total desc