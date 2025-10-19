/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits multiple base classes defining the same attribute,
 *              which may cause unexpected behavior due to attribute overriding conflicts.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/conflicting-attributes
 */

import python

/**
 * 判断函数实现是否为空
 * 当函数体仅包含pass语句或文档字符串表达式时视为空函数
 */
predicate is_empty_function(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * 检查函数是否包含对自身名称的super()调用
 * 此类调用表明方法通过调用父类实现正确处理了继承关系
 */
predicate has_super_call(FunctionObject func) {
  exists(Call superCallExpr, Call methodCallExpr, Attribute attributeAccess, GlobalVariable superGlobalVar |
    methodCallExpr.getScope() = func.getFunction() and
    methodCallExpr.getFunc() = attributeAccess and
    attributeAccess.getObject() = superCallExpr and
    attributeAccess.getName() = func.getName() and
    superCallExpr.getFunc() = superGlobalVar.getAnAccess() and
    superGlobalVar.getId() = "super"
  )
}

/**
 * 识别免于冲突检测的属性名
 * 当前仅包含'process_request'，因Python socketserver模块有特殊处理（见文档）
 */
predicate is_exempt_attribute(string attributeName) {
  attributeName = "process_request"  // Python文档推荐用于异步混入
}

from
  ClassObject derivedClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attributeName, 
  int basePos1, 
  int basePos2, 
  Object attributeInBase1, 
  Object attributeInBase2
where
  // 建立继承关系：确保两个不同的基类
  derivedClass.getBaseType(basePos1) = baseClass1 and
  derivedClass.getBaseType(basePos2) = baseClass2 and
  basePos1 < basePos2 and
  
  // 定位冲突属性：不同基类中存在同名属性
  attributeInBase1 = baseClass1.lookupAttribute(attributeName) and
  attributeInBase2 = baseClass2.lookupAttribute(attributeName) and
  attributeInBase1 != attributeInBase2 and
  
  // 过滤特殊方法名和豁免属性
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attributeName) and
  
  // 排除已正确处理继承的情况
  not has_super_call(attributeInBase1) and
  not is_empty_function(attributeInBase2) and
  not attributeInBase1.overrides(attributeInBase2) and
  not attributeInBase2.overrides(attributeInBase1) and
  
  // 确保派生类未解决冲突
  not derivedClass.declaresAttribute(attributeName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInBase1, attributeInBase1.toString(), 
  attributeInBase2, attributeInBase2.toString()