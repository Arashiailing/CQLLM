/**
 * @deprecated
 * @name 外部依赖关系统计
 * @description 分析并量化Python源文件所依赖的外部包的数量分布情况。
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 此查询提供Python项目外部依赖关系的量化分析，输出结果包含以下关键信息：
 *
 * 1. 源文件路径 - 作为依赖分析的主体文件
 * 2. 外部包对象 - 表示从PyPI或其他外部源引入的依赖包
 * 3. 版本信息 - 当可获取时包含的包版本详情
 * 4. 依赖计数 - 源文件中引用特定外部包的次数
 *
 * 当前实现输出两列数据（依赖实体和计数），虽然实际上涵盖了四个信息维度。
 * 理想情况下应输出三列以提供更细粒度的分析，但这需要调整底层数据架构。
 *
 * 文件路径添加了'/'前缀，以保持与仪表板数据库中使用的相对路径格式一致。
 */

// 定义查询变量，使用更具描述性的名称
from File sourceFile, ExternalPackage externalPkg, int depCount, string depEntity
where
  // 计算特定源文件对外部包的依赖数量
  depCount =
    strictcount(AstNode node |
      // 检查AST节点是否依赖于指定的外部包
      dependency(node, externalPkg) and
      // 确保AST节点位于当前分析的源文件中
      node.getLocation().getFile() = sourceFile
    ) and
  // 将源文件和外部包信息合并为统一的实体标识符
  depEntity = munge(sourceFile, externalPkg)
// 输出依赖实体及其计数，按依赖数量降序排列
select depEntity, depCount order by depCount desc