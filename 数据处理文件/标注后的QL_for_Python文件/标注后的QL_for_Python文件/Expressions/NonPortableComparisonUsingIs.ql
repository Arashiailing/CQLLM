/**
 * @name Non-portable comparison using is when operands support `__eq__`
 * @description Comparison using 'is' when equivalence is not the same as identity and may not be portable.
 * @kind problem
 * @tags portability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/comparison-using-is-non-portable
 */

import python  // 导入Python库，用于分析Python代码
import IsComparisons  // 导入IsComparisons库，用于处理比较操作相关的查询

// 定义一个查询，查找使用'is'进行比较的非便携性问题
from Compare comp, Cmpop op, ClassValue c  // 从比较表达式、比较操作符和类值中选择数据
where
  invalid_portable_is_comparison(comp, op, c) and  // 条件1：检查是否存在无效的便携性'is'比较
  exists(Expr sub | sub = comp.getASubExpression() |  // 条件2：存在子表达式满足以下条件
    cpython_interned_constant(sub) and  // 子表达式是CPython中的常量池中的常量
    not universally_interned_constant(sub)  // 子表达式不是普遍驻留的常量
  )
select comp,  // 选择比较表达式
  "The result of this comparison with '" + op.getSymbol() +  // 生成警告信息，指出比较结果可能因Python实现而异
    "' may differ between implementations of Python."
