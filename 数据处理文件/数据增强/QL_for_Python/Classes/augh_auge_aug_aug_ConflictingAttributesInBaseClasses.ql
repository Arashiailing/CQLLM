/**
 * @name 基类中的属性冲突
 * @description 检测继承自多个基类的类，其中多个基类定义了相同名称的属性。这种冲突可能导致由于属性解析歧义而产生意外行为。
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
 * 判断函数实现是否为空（仅包含pass语句或文档字符串）
 * 
 * 空实现通常不会导致实际冲突，因此可以忽略。
 */
predicate is_empty_implementation(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * 检查函数是否显式调用super()进行方法解析
 * 
 * 如果函数显式调用super()，则表明开发者已经意识到可能的方法解析顺序问题，
 * 并采取了措施来处理它，因此不应报告为冲突。
 */
predicate invokes_super(FunctionObject func) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * 识别冲突检测中豁免的属性名称
 * 
 * 某些属性在Python的特定模块中被设计为可以安全地冲突，
 * 例如socketserver模块中的process_request方法。
 */
predicate is_exempt_attribute(string attrName) {
  /*
   * 根据Python的socketserver模块文档，process_request方法被豁免：
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttributeName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attributeInFirstBase, 
  Object attributeInSecondBase
where
  // 建立继承关系：派生类继承自两个不同的基类（按继承顺序）
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // 在两个基类中定位相同名称的属性（确保是不同对象）
  attributeInFirstBase != attributeInSecondBase and
  attributeInFirstBase = firstBaseClass.lookupAttribute(conflictingAttributeName) and
  attributeInSecondBase = secondBaseClass.lookupAttribute(conflictingAttributeName) and
  
  // 排除特殊情况：这些情况虽然形式上是冲突，但实际不会导致问题
  not (
    // 特殊方法（双下划线包围的方法）通常遵循特定的解析规则
    conflictingAttributeName.matches("\\_\\_%\\_\\_") or
    
    // 已知豁免属性，如socketserver模块中的process_request方法
    is_exempt_attribute(conflictingAttributeName) or
    
    // 已通过super()调用处理方法解析，表明开发者已意识到问题
    invokes_super(attributeInFirstBase) or
    
    // 第二个基类中的空实现（通常不会造成实际冲突）
    is_empty_implementation(attributeInSecondBase) or
    
    // 两个属性间存在覆盖关系，表明它们是设计上的继承关系而非冲突
    attributeInFirstBase.overrides(attributeInSecondBase) or
    attributeInSecondBase.overrides(attributeInFirstBase) or
    
    // 派生类显式声明该属性，会解决基类间的冲突
    derivedClass.declaresAttribute(conflictingAttributeName)
  )

select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()