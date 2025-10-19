/**
 * @name 统计用户编写的Python代码行数
 * @description 计算源代码目录中用户编写的Python代码总行数，不包含自动生成的文件。
 *   本查询仅统计实际编写的代码行，忽略空白行和注释。注意：代码库中包含的外部库
 *   （无论是作为签入的虚拟环境还是供应商代码）目前都会被统计为用户编写的代码。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入Python分析模块
import semmle.python.filters.GeneratedCode // 导入自动生成代码过滤器模块

// 计算所有符合条件的用户代码模块的代码行数总和
select sum(Module srcModule |
    // 验证模块文件存在相对路径（表明它位于源代码目录中）
    exists(srcModule.getFile().getRelativePath()) and
    // 排除自动生成的文件
    not srcModule.getFile() instanceof GeneratedFile
  |
    // 获取源代码模块的有效代码行数
    srcModule.getMetrics().getNumberOfLinesOfCode()
  )