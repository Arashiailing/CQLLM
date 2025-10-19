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
 * 本查询分析Python源文件与外部包之间的依赖关系。
 * 
 * 输出数据包含以下关键信息：
 * 1. 依赖实体标识符 - 由源文件路径和外部包名组合而成
 * 2. 依赖计数 - 源文件中引用该外部包的次数
 * 
 * 尽管输出只有两列，但实际上涵盖了源文件、外部包、
 * 版本信息和依赖数量四个维度的数据。
 * 
 * 文件路径添加了'/'前缀，以匹配仪表板数据库中使用的
 * 相对文件路径格式。
 */

// 定义源文件、外部包、依赖计数和依赖实体
from File sourceFile, ExternalPackage externalPkg, int depCount, string depEntity
where
  // 计算源文件中对外部包的依赖数量
  depCount = strictcount(AstNode astNode |
    dependency(astNode, externalPkg) and  // 检查AST节点是否依赖于指定的外部包
    astNode.getLocation().getFile() = sourceFile  // 确保AST节点位于指定的源文件中
  ) and
  // 将源文件和外部包信息合并为单个实体标识符
  depEntity = munge(sourceFile, externalPkg)
// 选择依赖实体和依赖计数，并按依赖数量降序排列
select depEntity, depCount order by depCount desc