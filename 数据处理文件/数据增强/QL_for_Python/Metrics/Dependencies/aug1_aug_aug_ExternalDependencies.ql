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
 * 本查询用于分析Python代码库中的外部包依赖分布，提供关键指标：
 *
 * 分析维度：
 * 1. 源文件定位 - 标识包含外部依赖的Python源文件
 * 2. 包依赖识别 - 确定来自PyPI或其他外部仓库的具体包
 * 3. 版本追踪 - 捕获并记录包的版本约束信息（如适用）
 * 4. 引用频率统计 - 计算源文件中对外部包的引用次数
 *
 * 技术说明：
 * - 查询输出为两列格式，但实际包含上述四类信息
 * - 此设计确保与现有仪表板数据库架构的兼容性
 * - 修改列数需要同步更新仪表板数据库和提取器配置
 * - 文件路径添加前缀'/'以匹配仪表板数据库的相对路径标准
 */

// 主要分析流程：识别源文件-外部包关系并量化依赖强度
from File pySourceFile, int externalReferenceCount, string packageIdentifier, ExternalPackage importedPackage
where
  // 计算特定源文件中引用外部包的频次
  externalReferenceCount =
    strictcount(AstNode codeNode |
      // 验证代码节点是否引用了指定的外部包
      dependency(codeNode, importedPackage) and
      // 确保代码节点隶属于当前分析的源文件
      codeNode.getLocation().getFile() = pySourceFile
    ) and
  // 构造统一的包标识符，整合源文件和包信息
  packageIdentifier = munge(pySourceFile, importedPackage)
// 结果输出：按引用频次降序排列的包标识符及其计数
select packageIdentifier, externalReferenceCount order by externalReferenceCount desc