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
 * 本查询用于分析Python代码库中的外部包依赖关系，提供以下关键信息：
 *
 * 1. 源文档标识 - 标识包含依赖关系的Python源文件
 * 2. 外部依赖标识 - 表示从PyPI或其他外部仓库引入的包
 * 3. 版本规格 - 包含包的版本约束信息（如果存在）
 * 4. 引用频率 - 记录源文档中对外部依赖的引用次数
 *
 * 虽然查询输出仅显示两列，但实际包含上述四类信息。
 * 此设计确保与现有仪表板数据库架构的兼容性。
 * 任何列结构变更都需要相应调整仪表板数据库和数据提取器。
 *
 * 注意：文件路径添加了'/'前缀，以匹配仪表板数据库中的相对路径格式。
 */

// 主查询：分析源文档与外部依赖的关联关系并计算引用频率
from File sourceDocument, int refFrequency, string packageIdentifier, ExternalPackage externalDependency
where
  // 计算源文档中对外部依赖的引用次数
  refFrequency =
    strictcount(AstNode syntaxNode |
      // 验证语法节点是否依赖于指定的外部包
      dependency(syntaxNode, externalDependency) and
      // 确保语法节点属于当前分析的源文档
      syntaxNode.getLocation().getFile() = sourceDocument
    ) and
  // 构建复合标识符，整合源文档和外部依赖信息
  packageIdentifier = munge(sourceDocument, externalDependency)
// 输出结果：按引用频率降序排列的包标识符和频率计数
select packageIdentifier, refFrequency order by refFrequency desc