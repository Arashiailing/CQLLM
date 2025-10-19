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
 * 分析目标：评估Python代码库中外部包依赖的使用模式，包含以下分析维度：
 *
 * 核心分析要素：
 * 1. 源文件定位 - 识别包含外部依赖引用的Python源文件
 * 2. 外部包识别 - 检测来自PyPI或其他外部仓库的包依赖
 * 3. 版本规格捕获 - 记录包的版本约束信息（如果存在）
 * 4. 使用频率统计 - 计算源文件中对外部包的引用频次
 *
 * 技术实现：
 * - 输出格式为两列，但实际包含上述四类分析数据
 * - 当前实现确保与仪表板数据库架构兼容
 * - 如需调整输出列数，必须同步更新仪表板数据库和提取器配置
 * - 文件路径前添加'/'以满足仪表板数据库的相对路径要求
 */

// 主要分析流程：建立源文件与外部包的映射关系，并量化依赖使用强度
from File sourceFile, int usageFrequency, string packageSignature, ExternalPackage externalPackage
where
  // 阶段1：统计指定源文件中引用特定外部包的总频次
  usageFrequency =
    strictcount(AstNode syntaxNode |
      // 确认语法节点引用了目标外部包
      dependency(syntaxNode, externalPackage) and
      // 验证语法节点属于当前分析的源文件
      syntaxNode.getLocation().getFile() = sourceFile
    ) and
  // 阶段2：创建标准化的包签名，整合文件和包信息
  packageSignature = munge(sourceFile, externalPackage)
// 结果呈现：按使用频率降序排列的包签名及其计数
select packageSignature, usageFrequency order by usageFrequency desc