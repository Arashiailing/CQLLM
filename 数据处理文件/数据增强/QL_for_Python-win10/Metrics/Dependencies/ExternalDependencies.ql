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
 * 这两列编码了四个逻辑列：
 *
 * 1. 依赖关系来源的Python源文件
 * 2. 包对象，理想情况下指的是PyPI或类似的外部提供的包
 * 3. 该包对象的版本（如果已知）
 * 4. 从源文件到包的依赖数量
 *
 * 理想情况下，这个查询将返回三列，
 * 但这需要更改仪表板数据库架构和仪表板提取器。
 *
 * 第一列（Python源文件）前面加上了一个'/'，
 * 以便文件路径与仪表板数据库中使用的文件路径匹配，
 * 后者是相对于源存档位置的隐式相对路径。
 */

// 定义谓词函数src_package_count，用于计算特定源文件对特定外部包的依赖数量
predicate src_package_count(File sourceFile, ExternalPackage package, int total) {
  // 使用strictcount统计满足条件的AstNode节点数量，并将结果赋值给total
  total =
    strictcount(AstNode src |
      dependency(src, package) and // 检查src节点是否依赖于指定的package
      src.getLocation().getFile() = sourceFile // 检查src节点所在的文件是否是指定的sourceFile
    )
}

// 从File类型的sourceFile、int类型的total、string类型的entity和ExternalPackage类型的package中选择数据
from File sourceFile, int total, string entity, ExternalPackage package
where
  // 条件1：调用src_package_count谓词函数，确保sourceFile对package有total个依赖
  src_package_count(sourceFile, package, total) and
  // 条件2：将sourceFile和package进行munge操作，并将结果赋值给entity
  entity = munge(sourceFile, package)
// 选择entity和total列，并按total降序排列结果
select entity, total order by total desc
