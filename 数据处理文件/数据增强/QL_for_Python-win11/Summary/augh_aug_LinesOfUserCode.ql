/**
 * @name Python用户代码行数统计
 * @description 统计源代码库中用户编写的Python代码总行数，过滤掉自动生成的文件。
 *   本查询计算的是实际代码行数，不包括空行和注释。注意：当前实现将代码库中的外部依赖
 *   （如提交的虚拟环境或第三方代码）视为用户编写的代码。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python
import semmle.python.filters.GeneratedCode

// 计算用户编写的Python模块代码行数总和
select sum(Module pyModule |
    (
      // 确保模块是源代码的一部分（具有相对路径）
      exists(pyModule.getFile().getRelativePath()) and
      // 排除自动生成的文件
      not pyModule.getFile() instanceof GeneratedFile
    )
  |
    // 获取每个模块的代码行数
    pyModule.getMetrics().getNumberOfLinesOfCode()
  )