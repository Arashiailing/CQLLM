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
 * 此查询分析Python代码中的外部包依赖情况，提取以下关键信息：
 *
 * - 源文件标识 - 包含依赖关系的Python源文件
 * - 外部包标识 - 来自PyPI或其他外部仓库的包
 * - 版本信息 - 包的版本详情（如果可用）
 * - 引用频率 - 源文件中对外部包的引用次数
 *
 * 查询结果仅显示两列，但实际包含上述四类信息。
 * 这种设计是为了与现有仪表板数据库架构保持兼容。
 * 任何列数变更都需要相应调整仪表板数据库和提取器。
 *
 * 注意：文件路径前添加了'/'前缀，以匹配仪表板数据库中的相对路径格式。
 */

// 主查询逻辑：分析源文件与外部包的依赖关系并统计引用频率
from File pythonFile, ExternalPackage extPkg
where
  // 确保文件中至少存在一个对外部包的引用
  exists(AstNode node |
    dependency(node, extPkg) and
    node.getLocation().getFile() = pythonFile
  )
// 计算每个文件-包对的引用次数并生成标识符
select
  // 构建复合标识符，包含源文件和包信息
  munge(pythonFile, extPkg) as pkgIdentifier,
  // 统计源文件中引用特定外部包的次数
  strictcount(AstNode node |
    dependency(node, extPkg) and
    node.getLocation().getFile() = pythonFile
  ) as refCount
order by refCount desc