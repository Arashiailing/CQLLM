/**
 * @name Mismatch in multiple assignment
 * @description Assigning multiple variables without ensuring that you define a
 *              value for each variable causes an exception at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mismatched-multiple-assignment
 */

import python

// 计算表达式列表中元素的数量
private int getExprListCount(ExprList exprList) { 
    result = count(exprList.getAnItem()) 
}

from Assign assignment, int leftCount, int rightCount, Location errorLocation, string containerType
where
    // 情况1：直接元组/列表赋值时的元素数量不匹配
    exists(ExprList leftElements, ExprList rightElements |
        (
            // 检查赋值目标是否为元组或列表
            assignment.getATarget().(Tuple).getElts() = leftElements or
            assignment.getATarget().(List).getElts() = leftElements
        ) and
        (
            // 检查赋值源是否为元组或列表
            (assignment.getValue().(Tuple).getElts() = rightElements and containerType = "tuple") or
            (assignment.getValue().(List).getElts() = rightElements and containerType = "list")
        ) and
        // 计算左右两侧元素数量并比较
        leftCount = getExprListCount(leftElements) and
        rightCount = getExprListCount(rightElements) and
        leftCount != rightCount and
        // 确保两侧均未使用星号解包
        not exists(Starred unpack | 
            leftElements.getAnItem() = unpack or 
            rightElements.getAnItem() = unpack
        ) and
        // 定位问题位置
        errorLocation = assignment.getValue().getLocation()
    )
    or
    // 情况2：通过引用指向元组时的元素数量不匹配
    exists(ExprList leftElements, TupleValue rightTuple, AstNode tupleOrigin |
        (
            // 检查赋值目标是否为元组或列表
            assignment.getATarget().(Tuple).getElts() = leftElements or
            assignment.getATarget().(List).getElts() = leftElements
        ) and
        // 检查赋值源是否指向元组值
        assignment.getValue().pointsTo(rightTuple, tupleOrigin) and
        // 计算元素数量并比较
        leftCount = getExprListCount(leftElements) and
        rightCount = rightTuple.length() and
        leftCount != rightCount and
        // 确保左侧未使用星号解包
        not leftElements.getAnItem() instanceof Starred and
        // 定位问题位置并设置容器类型
        errorLocation = tupleOrigin.getLocation() and
        containerType = "tuple"
    )
select assignment,
    // 生成问题描述信息
    "Left hand side of assignment contains " + leftCount +
    " variables, but right hand side is a $@ of length " + rightCount + ".", 
    errorLocation, containerType