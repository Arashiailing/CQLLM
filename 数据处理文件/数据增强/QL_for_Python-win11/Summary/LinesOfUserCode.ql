/**
 * @name 数据库中用户编写的Python代码总行数
 * @description 来自源代码目录的Python代码的总行数，不包括自动生成的文件。
 *   此查询计算代码行数，不包括空白或注释。注意：如果外部库包含在代码库中，
 *   无论是在已签入的虚拟环境中还是作为供应商代码，目前都将被计为用户编写的代码。
 * @kind metric
 * @tags summary
 *       代码行数
 *       调试
 * @id py/summary/lines-of-user-code
 */

import python // 导入python模块
import semmle.python.filters.GeneratedCode // 导入GeneratedCode过滤器模块

// 选择所有符合条件的模块，并计算其代码行数之和
select sum(Module m |
    // 确保模块文件有相对路径
    exists(m.getFile().getRelativePath()) and
    // 排除自动生成的文件
    not m.getFile() instanceof GeneratedFile
  |
    // 获取模块的代码行数指标
    m.getMetrics().getNumberOfLinesOfCode()
  )
