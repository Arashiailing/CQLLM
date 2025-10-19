/**
 * @name Unsupported format character
 * @description An unsupported format character in a format string
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// 导入Python分析核心模块，提供代码解析基础能力
import python
// 导入字符串处理专用模块，支持格式字符串分析
import semmle.python.strings

/* 
 * 查询逻辑分解：
 * 1. 数据源：从所有Python表达式(e)中扫描
 * 2. 过滤条件：定位包含非法转换说明符的表达式
 * 3. 结果输出：标记问题表达式并生成诊断信息
 */
from Expr e, int specifierPosition
// 定位非法转换说明符的具体位置
where specifierPosition = illegal_conversion_specifier(e)
// 生成包含位置索引和表达式内容的错误报告
select e, "Invalid conversion specifier at index " + specifierPosition + " of " + repr(e) + "."