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
 * 此查询通过以下逻辑检测问题：
 * 1. 定位 super() 调用表达式
 * 2. 验证调用发生在方法定义内
 * 3. 确认所属类为旧式类
 * 4. 排除类型推断失败的类
 */
from Call superInvocation
where exists(Function enclosingMethod, ClassObject hostClass |
    // 关联调用表达式与其所在方法
    superInvocation.getScope() = enclosingMethod and
    // 关联方法与其所属类
    enclosingMethod.getScope() = hostClass.getPyClass() and
    // 确保类型分析成功
    not hostClass.failedInference() and
    // 识别旧式类特征（非新式类）
    not hostClass.isNewStyle() and
    // 验证调用目标是 super 函数
    superInvocation.getFunc().(Name).getId() = "super"
)
// 输出问题表达式及错误提示
select superInvocation, "'super()' will not work in old-style classes."