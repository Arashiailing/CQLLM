/**
 * @deprecated
 * @name Mostly duplicate module
 * @description There is another file that shares a lot of the code with this file. Merge the two files to improve maintainability.
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
 * @id py/mostly-duplicate-file
 */

import python

// 此查询选择两个模块对象和一个描述性字符串，但未应用任何过滤条件
from 
    Module sourceModule, 
    Module targetModule, 
    string description
where 
    none()
select 
    sourceModule, 
    description, 
    targetModule, 
    targetModule.getName()