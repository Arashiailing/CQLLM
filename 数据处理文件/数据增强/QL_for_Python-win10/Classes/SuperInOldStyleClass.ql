/**
 * @name 'super' in old style class
 * @description 使用 super() 访问继承的方法在旧式类中是不被支持的。
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// 定义一个谓词函数，用于检测在旧式类中使用了 super()
predicate uses_of_super_in_old_style_class(Call s) {
  // 存在一个函数 f 和一个类对象 c，使得以下条件成立：
  exists(Function f, ClassObject c |
    // 调用 s 的作用域是函数 f
    s.getScope() = f and
    // 函数 f 的作用域是类对象 c 的 Python 类
    f.getScope() = c.getPyClass() and
    // 类对象 c 没有失败的类型推断
    not c.failedInference() and
    // 类对象 c 不是新式类
    not c.isNewStyle() and
    // 调用的函数名是 "super"
    s.getFunc().(Name).getId() = "super"
  )
}

// 从所有调用点开始查询
from Call c
// 条件是调用点满足在旧式类中使用了 super()
where uses_of_super_in_old_style_class(c)
// 选择这些调用点，并给出错误信息
select c, "'super()' will not work in old-style classes."
