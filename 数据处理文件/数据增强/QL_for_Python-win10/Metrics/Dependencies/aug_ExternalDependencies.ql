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
 * 查询结果包含两个输出列，但实际上编码了四个逻辑信息：
 *
 * 1. Python源文件路径 - 标识依赖关系的来源文件
 * 2. 外部包对象 - 通常指PyPI或其他外部仓库提供的包
 * 3. 包版本信息 - 如果能够获取到的话
 * 4. 依赖计数 - 源文件中引用该包的次数
 *
 * 当前查询设计为返回两列数据，这是为了兼容现有的仪表板数据库架构。
 * 如果要返回三列或更多列，需要修改仪表板数据库架构和提取器。
 *
 * 注意：文件路径前添加了'/'前缀，以确保路径格式与仪表板数据库中使用的相对路径一致。
 */

// 主查询：识别源文件与外部包之间的依赖关系并统计数量
from File srcFile, int depCount, string pkgEntity, ExternalPackage extPkg
where
  // 计算特定源文件对特定外部包的依赖数量
  depCount =
    strictcount(AstNode node |
      dependency(node, extPkg) and // 检查AST节点是否依赖于指定的外部包
      node.getLocation().getFile() = srcFile // 确保节点位于指定的源文件中
    ) and
  // 将源文件和包信息合并为单一实体标识符
  pkgEntity = munge(srcFile, extPkg)
// 输出结果：实体标识符和依赖计数，按依赖数量降序排列
select pkgEntity, depCount order by depCount desc