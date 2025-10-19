/**
 * @name Multiple imports on one line
 * @description Defining multiple imports on one line makes code more difficult to read;
 *              PEP8 states that imports should usually be on separate lines.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

/*
 * Look for imports of the form:
 * import modA, modB
 * (Imports should be one per line according PEP 8)
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 定义一个谓词函数，用于判断是否为多模块导入
predicate multiple_import(Import imp) { 
    // 获取导入语句中的模块名称列表，并检查其数量是否大于1
    count(imp.getAName()) > 1 and 
    // 确保该导入语句不是从某个模块中导入特定名称的形式
    not imp.isFromImport() 
}

// 从所有导入语句中查找符合multiple_import条件的导入语句
from Import i
where multiple_import(i)
select i, "Multiple imports on one line."
