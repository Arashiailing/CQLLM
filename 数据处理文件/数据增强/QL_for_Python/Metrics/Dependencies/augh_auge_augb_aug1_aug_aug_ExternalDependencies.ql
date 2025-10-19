/**
 * @deprecated
 * @name 外部依赖关系分析
 * @description 量化Python源文件中外部包依赖的使用频率
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType externalDependency
 * @id py/external-dependencies
 */

import python
import semmle.python.dependencies.TechInventory

/*
 * 查询目标：识别并统计Python代码库中外部包依赖的使用情况，提供以下分析维度：
 *
 * 核心分析要素：
 * 1. 源代码文件定位 - 确定包含外部依赖引用的Python源文件
 * 2. 外部包识别 - 检测引用自PyPI或其他外部仓库的包
 * 3. 版本信息捕获 - 记录包的版本约束（如果可用）
 * 4. 使用频率计算 - 统计源文件中对外部包的引用次数
 *
 * 技术实现说明：
 * - 输出格式为两列，包含上述四类分析数据
 * - 当前实现与仪表板数据库架构保持兼容
 * - 输出列数变更需同步更新仪表板数据库和提取器配置
 * - 文件路径前添加'/'以满足仪表板数据库的相对路径格式要求
 */

// 分析主体：建立源文件与外部包的映射关系，并量化依赖使用强度
from File sourceFile, int usageCount, string packageId, ExternalPackage externalPackage
where
  // 计算逻辑：统计指定源文件中引用特定外部包的次数
  usageCount =
    strictcount(AstNode node |
      // 检查代码节点是否引用了目标外部包
      dependency(node, externalPackage) and
      // 确保代码节点属于当前分析的源文件
      node.getLocation().getFile() = sourceFile
    ) and
  // 标识符生成：创建包含文件和包信息的标准化标识符
  packageId = munge(sourceFile, externalPackage)
// 输出结果：按使用频率降序排列的包标识符及其使用次数
select packageId, usageCount order by usageCount desc