/**
 * @name 'super' in old style class
 * @description 检测在旧式类中使用 super() 调用继承方法的情况，这种用法不被支持。
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// 谓词定义：识别在旧式类中对 super() 的不当调用
predicate superCallInOldStyleClass(Call superCall) {
  // 验证调用是否位于函数和类的嵌套作用域内，并满足以下条件：
  exists(Function parentFunction, ClassObject parentClass |
    // 确认调用点位于函数范围内
    superCall.getScope() = parentFunction and
    // 确认函数位于类范围内
    parentFunction.getScope() = parentClass.getPyClass() and
    // 确认类类型推断成功
    not parentClass.failedInference() and
    // 确认类为旧式类（非新式类）
    not parentClass.isNewStyle() and
    // 确认调用的是名为 "super" 的函数
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 查询所有在旧式类中无效的 super() 调用
from Call problematicSuperCall
// 应用筛选条件：调用必须发生在旧式类上下文中
where superCallInOldStyleClass(problematicSuperCall)
// 返回结果及对应的错误提示信息
select problematicSuperCall, "'super()' will not work in old-style classes."