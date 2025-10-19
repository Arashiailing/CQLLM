/**
 * @name 'super' in old style class
 * @description 旧式类中不支持使用 super() 访问继承方法，此查询检测此类不兼容用法。
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

from Call faultySuperCall
// 直接在查询中整合谓词逻辑，检测旧式类中的 super() 调用
where exists(Function hostFunction, ClassObject hostClass |
    // 调用必须位于某个函数作用域内
    faultySuperCall.getScope() = hostFunction and
    // 该函数必须定义在类作用域内
    hostFunction.getScope() = hostClass.getPyClass() and
    // 确保类类型分析成功
    not hostClass.failedInference() and
    // 验证目标类是旧式类（非新式类）
    not hostClass.isNewStyle() and
    // 确认调用目标是 super() 函数
    faultySuperCall.getFunc().(Name).getId() = "super"
)
// 输出问题调用点及错误信息
select faultySuperCall, "'super()' will not work in old-style classes."