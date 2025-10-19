/**
 * @deprecated
 * @name 外部依赖关系分析
 * @description 统计Python源文件中引用的外部包依赖数量。
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 本查询用于分析Python源文件与外部包之间的依赖关系，并计算每个源文件
 * 对各个外部包的依赖数量。查询结果包含两列数据：
 *
 * 1. depEntity - 包含源文件路径、外部包名称和版本信息的复合标识符
 * 2. depCount - 表示源文件对外部包的依赖数量
 *
 * 源文件路径会添加'/'前缀，以确保与仪表板数据库中的路径格式一致。
 * 此格式是相对于源存档位置的隐式相对路径。
 */

from File sourceFile, int depCount, string depEntity, ExternalPackage externalPkg
where
  // 计算特定源文件对特定外部包的依赖数量
  depCount =
    strictcount(AstNode astNode |
      // 检查AST节点是否依赖于指定的外部包
      dependency(astNode, externalPkg) and
      // 确保AST节点位于指定的源文件中
      astNode.getLocation().getFile() = sourceFile
    ) and
  // 生成包含源文件和外部包信息的复合实体标识符
  depEntity = munge(sourceFile, externalPkg)
// 选择复合实体标识符和依赖计数，并按依赖计数降序排列
select depEntity, depCount order by depCount desc