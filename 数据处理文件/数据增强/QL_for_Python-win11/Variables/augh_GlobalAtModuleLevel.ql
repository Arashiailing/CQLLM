/**
 * @name 模块级别冗余的 'global' 声明
 * @description 识别 Python 代码中在模块级别冗余的 'global' 变量声明。
 *              在 Python 中，在模块级别使用 'global' 语句是不必要的，
 *              因为在模块级别声明的所有变量默认都是全局的。
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// 导入 Python 模块，用于代码分析和 AST 遍历
import python

// 识别所有在模块作用域中出现的全局变量声明
from Global globalDeclaration
where globalDeclaration.getScope() instanceof Module // 筛选条件：仅选择在模块级别的全局声明
select globalDeclaration, "Declaring '" + globalDeclaration.getAName() + "' as global at module-level is redundant." // 输出全局声明和警告信息