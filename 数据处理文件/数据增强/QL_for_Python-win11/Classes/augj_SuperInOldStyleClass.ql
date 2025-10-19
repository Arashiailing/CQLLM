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

/**
 * 识别在旧式类中使用 super() 的调用点
 * 当一个方法内部调用了 super()，且该方法属于一个旧式类时，
 * 此谓词会识别出这样的调用点。
 */
predicate superCallInOldClass(Call superInvocation) {
  exists(Function method, ClassObject cls |
    // 调用点位于某个方法内
    superInvocation.getScope() = method and
    // 该方法定义在某个类中
    method.getScope() = cls.getPyClass() and
    // 确保类的类型推断没有失败
    not cls.failedInference() and
    // 确认这是一个旧式类
    not cls.isNewStyle() and
    // 确认调用的是 super 函数
    superInvocation.getFunc().(Name).getId() = "super"
  )
}

// 查找所有在旧式类中使用 super() 的调用点
from Call superCall
// 筛选出在旧式类中使用 super() 的调用点
where superCallInOldClass(superCall)
// 输出结果和错误信息
select superCall, "'super()' will not work in old-style classes."