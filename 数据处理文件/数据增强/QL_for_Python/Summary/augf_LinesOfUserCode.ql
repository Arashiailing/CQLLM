/**
 * @name 用户编写的Python代码行数统计
 * @description 统计源代码目录中用户编写的Python代码总行数，自动生成的文件不计入。
 *   该查询计算的是实际代码行数，不包括空白行和注释。需要注意的是，如果代码库中包含
 *   外部库（无论是在签入的虚拟环境中还是作为供应商代码），目前也会被计为用户编写的代码。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入Python分析模块
import semmle.python.filters.GeneratedCode // 导入自动生成代码过滤器模块

// 计算符合条件的Python模块的代码行数总和
select sum(Module pythonModule |
    // 检查模块文件是否具有相对路径（确保是源代码的一部分）
    exists(pythonModule.getFile().getRelativePath()) and
    // 排除被标记为自动生成的文件
    not pythonModule.getFile() instanceof GeneratedFile
  |
    // 获取模块的实际代码行数（不包括空白行和注释）
    pythonModule.getMetrics().getNumberOfLinesOfCode()
  )