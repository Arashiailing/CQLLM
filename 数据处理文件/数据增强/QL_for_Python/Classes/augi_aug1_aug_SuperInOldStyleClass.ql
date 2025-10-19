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
 * 查询目标：识别在旧式类中使用 super() 的表达式
 * 
 * 检测原理：
 * 在 Python 中，旧式类（未继承自 object 的类）不支持使用 super() 函数。
 * 此查询通过以下步骤识别此类问题：
 * 1. 查找所有 super() 函数调用
 * 2. 确认调用位于方法定义内部
 * 3. 验证该方法属于一个旧式类
 * 4. 排除类型分析失败的类
 */
from Call superCall
where exists(Function containingMethod, ClassObject parentClass |
    // 建立调用表达式与包含方法的关系
    superCall.getScope() = containingMethod and
    // 建立方法与所属类的关系
    containingMethod.getScope() = parentClass.getPyClass() and
    // 确保类的类型分析成功
    not parentClass.failedInference() and
    // 确认类是旧式类（非新式类）
    not parentClass.isNewStyle()
) and
    // 验证调用的是 super 函数
    superCall.getFunc().(Name).getId() = "super"
// 输出问题表达式及错误提示
select superCall, "'super()' will not work in old-style classes."