/**
 * @name CWE CATEGORY: 7PK - Security Features
 * @description nan
 * @id py/compile_helpers
 */

import python

// 定义一个谓词函数，用于检查代码中是否存在不可达的代码
predicate reportable_unreachable(Stmt s) {
  // 检查是否存在一个语句，该语句位于文件的末尾
  exists(File f | f.getLastItem() = s.getScope() |
    // 如果文件的最后一项与当前语句的作用域相同，则认为该语句是不可达的
    f.getLastItem() = s.getASubExpression().getNode()
  )
}

// 查询所有不可达的代码并选择相应的语句和描述信息
from Stmt s
where reportable_unreachable(s)
select s, "This statement is unreachable."