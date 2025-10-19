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
 * 查询目标：检测在旧式类中使用 super() 的表达式
 * 
 * 检测逻辑：
 * 1. 识别所有 super() 函数调用
 * 2. 确认调用位于类方法内部
 * 3. 验证所属类为旧式类（非新式类）
 * 4. 排除类型分析失败的类
 * 
 * 旧式类是 Python 2.1 之前引入的类定义方式，它们不支持 super() 函数。
 * 在旧式类中使用 super() 会导致运行时错误。
 */
from Call superCall
where exists(Function containingMethod, ClassObject parentClass |
    // === 调用上下文检查 ===
    // 关联 super() 调用与其所在方法
    superCall.getScope() = containingMethod and
    
    // === 类属关系检查 ===
    // 关联方法与其所属类
    containingMethod.getScope() = parentClass.getPyClass() and
    
    // === 类型分析检查 ===
    // 确保类型分析成功，避免误报
    not parentClass.failedInference() and
    
    // === 类类型检查 ===
    // 识别旧式类特征（非新式类）
    not parentClass.isNewStyle() and
    
    // === 调用目标检查 ===
    // 验证调用目标是 super 函数
    superCall.getFunc().(Name).getId() = "super"
)
// 输出问题表达式及错误提示
select superCall, "'super()' will not work in old-style classes."