/**
 * @name 'super' in old style class
 * @description 检测旧式类中使用 super() 的不兼容模式
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
 * 检测逻辑：
 * 1. 定位所有 super() 函数调用点
 * 2. 验证调用发生在类方法上下文中
 * 3. 确认所属类为旧式类（非新式类）
 * 4. 排除类型分析失败的类
 * 
 * 技术背景：
 * 旧式类（Python 2.1 前的类定义）不支持 super() 机制，
 * 在此类中使用 super() 会导致运行时 AttributeError 异常。
 */
from Call superInvocation
where exists(Function methodContext, ClassObject classContainer |
    // === 调用上下文验证 ===
    superInvocation.getScope() = methodContext and  // super调用位于方法内
    methodContext.getScope() = classContainer.getPyClass() and  // 方法属于类
    
    // === 类属性验证 ===
    not classContainer.failedInference() and  // 确保类型分析有效
    not classContainer.isNewStyle() and       // 确认是旧式类
    
    // === 调用目标验证 ===
    superInvocation.getFunc().(Name).getId() = "super"  // 明确调用super函数
)
// 输出问题位置及错误提示
select superInvocation, "In old-style classes, 'super()' is not supported and will cause runtime errors."