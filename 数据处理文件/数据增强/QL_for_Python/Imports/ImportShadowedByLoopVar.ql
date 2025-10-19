/**
 * @name Import shadowed by loop variable
 * @description A loop variable shadows an import.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// 导入Python库，用于分析Python代码
import python

// 定义一个谓词函数，判断变量是否被导入的模块名所遮蔽
predicate shadowsImport(Variable l) {
  // 存在一个导入语句i和一个名称shadow，使得以下条件成立：
  exists(Import i, Name shadow |
    // shadow是导入模块的名称
    shadow = i.getAName().getAsname() and
    // shadow的标识符与变量l的标识符相同
    shadow.getId() = l.getId() and
    // 导入的作用域包含变量l的作用域
    i.getScope() = l.getScope().getScope*()
  )
}

// 从所有变量和名称定义中选择符合条件的项
from Variable l, Name defn
// 条件1：变量l遮蔽了一个导入
where shadowsImport(l) and
      // 条件2：defn定义了变量l
      defn.defines(l) and
      // 条件3：存在一个for循环，其目标为defn
      exists(For for | defn = for.getTarget())
// 选择defn并生成警告信息，指出循环变量遮蔽了导入
select defn, "Loop variable '" + l.getId() + "' shadows an import."
