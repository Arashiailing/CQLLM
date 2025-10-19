/**
 * @deprecated
 * @name Mostly duplicate class
 * @description 
 * More than 80% of the methods in this class are duplicated in another class. 
 * Create a common supertype to improve code sharing.
 * @kind problem
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mostly-duplicate-class
 */

import python

// 声明查询变量：
// - `c`: 当前分析的类
// - `other`: 可能包含重复代码的对比类
// - `message`: 描述重复问题的诊断消息
from 
    Class c, 
    Class other, 
    string message
where 
    // 无过滤条件（原始查询逻辑）
    none()
select 
    c, 
    message, 
    other, 
    other.getName()