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
 * 查询目标：分析Python代码库中的外部包依赖使用情况，提供以下分析维度：
 *
 * 主要分析要素：
 * 1. 源文件识别 - 定位包含外部依赖的Python源文件
 * 2. 外部包检测 - 识别来自PyPI或其他外部仓库的包引用
 * 3. 版本约束记录 - 捕获包的版本规格信息（如存在）
 * 4. 引用频率统计 - 计算源文件中对外部包的引用次数
 *
 * 实现细节：
 * - 输出格式为两列，但实际包含上述四类分析数据
 * - 当前设计确保与仪表板数据库架构兼容
 * - 如需修改输出列数，必须同步更新仪表板数据库和提取器配置
 * - 文件路径前添加'/'以满足仪表板数据库的相对路径要求
 */

// 核心分析逻辑：建立源文件与外部包的关联，并量化依赖强度
from File pythonFile, int refCount, string pkgIdentifier, ExternalPackage extPkg
where
  // 步骤1：计算特定源文件中引用外部包的总次数
  refCount =
    strictcount(AstNode codeNode |
      // 验证代码节点是否引用了指定的外部包
      dependency(codeNode, extPkg) and
      // 确认代码节点属于当前分析的源文件
      codeNode.getLocation().getFile() = pythonFile
    ) and
  // 步骤2：生成标准化的包标识符，整合文件和包信息
  pkgIdentifier = munge(pythonFile, extPkg)
// 结果输出：按引用频率降序排列的包标识符及其计数
select pkgIdentifier, refCount order by refCount desc