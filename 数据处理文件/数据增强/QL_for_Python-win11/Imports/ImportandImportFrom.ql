/**
 * @name Module is imported with 'import' and 'import from'
 * @description A module is imported with the "import" and "import from" statements
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision very-high
 * @id py/import-and-import-from
 */

// 导入Python库，用于分析Python代码
import python

// 定义一个谓词函数，用于检测模块是否同时使用了`import`和`import from`语句进行导入
predicate import_and_import_from(Import i1, Import i2, Module m) {
  // 确保两个导入语句属于同一个封闭模块
  i1.getEnclosingModule() = i2.getEnclosingModule() and
  // 检查是否存在两个导入表达式和一个导入成员满足以下条件
  exists(ImportExpr e1, ImportExpr e2, ImportMember im |
    // 第一个导入表达式与第一个导入语句相关联
    e1 = i1.getAName().getValue() and 
    // 第二个导入表达式与第二个导入语句相关联
    im = i2.getAName().getValue() and 
    e2 = im.getModule()
  |
    // 两个导入表达式的名称都与模块名称相同
    e1.getName() = m.getName() and e2.getName() = m.getName()
  )
}

// 从所有语句和模块中选择数据
from Stmt i1, Stmt i2, Module m
// 使用谓词函数过滤出符合条件的导入语句和模块
where import_and_import_from(i1, i2, m)
// 选择第一个导入语句并生成警告信息，指出模块同时使用了`import`和`import from`语句进行导入
select i1, "Module '" + m.getName() + "' is imported with both 'import' and 'import from'."
