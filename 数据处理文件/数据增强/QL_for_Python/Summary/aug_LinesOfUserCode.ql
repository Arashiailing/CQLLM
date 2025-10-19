/**
 * @name 用户编写的Python代码总行数统计
 * @description 计算源代码中用户编写的Python代码总行数，排除自动生成的文件。
 *   该查询统计的是实际代码行数，不包含空白行和注释行。注意：当前实现将包含在代码库中的
 *   外部库（如签入的虚拟环境或供应商代码）视为用户编写的代码。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python
import semmle.python.filters.GeneratedCode

// 计算用户编写的Python代码总行数
select sum(Module pythonModule |
    // 检查模块是否具有相对路径（表明它是源代码的一部分）
    exists(pythonModule.getFile().getRelativePath()) and
    // 排除自动生成的文件
    not pythonModule.getFile() instanceof GeneratedFile
  |
    // 获取模块的代码行数指标
    pythonModule.getMetrics().getNumberOfLinesOfCode()
  )