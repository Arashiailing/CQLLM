/**
 * @name Conflicting attributes in base classes
 * @description When a class subclasses multiple base classes and more than one base class defines the same attribute, attribute overriding may result in unexpected behavior by instances of this class.
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

// 定义一个谓词函数，用于判断给定的Python函数对象是否不执行任何操作。
predicate does_nothing(PyFunctionObject f) {
  // 检查函数体中是否存在非Pass语句或文档字符串以外的表达式语句。
  not exists(Stmt s | s.getScope() = f.getFunction() |
    not s instanceof Pass and not s.(ExprStmt).getValue() = f.getFunction().getDocString()
  )
}

/* 如果一个方法执行了super()调用，那么它是OK的，因为被覆盖的方法将被调用 */
// 定义一个谓词函数，用于判断给定的函数对象是否调用了super()。
predicate calls_super(FunctionObject f) {
  // 检查函数体内是否存在对super的调用。
  exists(Call sup, Call meth, Attribute attr, GlobalVariable v |
    meth.getScope() = f.getFunction() and
    meth.getFunc() = attr and
    attr.getObject() = sup and
    attr.getName() = f.getName() and
    sup.getFunc() = v.getAnAccess() and
    v.getId() = "super"
  )
}

/** Holds if the given name is allowed for some reason */
// 定义一个谓词函数，用于判断给定的名称是否由于某种原因被允许。
predicate allowed(string name) {
  /*
   * The standard library specifically recommends this :(
   * See https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */

  // 检查名称是否为"process_request"。
  name = "process_request"
}

from
  ClassObject c, ClassObject b1, ClassObject b2, string name, int i1, int i2, Object o1, Object o2
where
  // 获取类c的第i1个基类b1。
  c.getBaseType(i1) = b1 and
  // 获取类c的第i2个基类b2。
  c.getBaseType(i2) = b2 and
  // 确保i1小于i2。
  i1 < i2 and
  // 确保o1和o2是不同的对象。
  o1 != o2 and
  // 在基类b1中查找名为name的属性并赋值给o1。
  o1 = b1.lookupAttribute(name) and
  // 在基类b2中查找名为name的属性并赋值给o2。
  o2 = b2.lookupAttribute(name) and
  // 确保属性名不匹配双下划线模式。
  not name.matches("\\_\\_%\\_\\_") and
  // 确保o1没有调用super()。
  not calls_super(o1) and
  // 确保o2不是空函数。
  not does_nothing(o2) and
  // 确保属性名不被允许。
  not allowed(name) and
  // 确保o1不覆盖o2。
  not o1.overrides(o2) and
  // 确保o2不覆盖o1。
  not o2.overrides(o1) and
  // 确保类c没有声明该属性。
  not c.declaresAttribute(name)
select c, "Base classes have conflicting values for attribute '" + name + "': $@ and $@.", o1,
  // 选择类c，并报告基类中冲突的属性值。
  o1.toString(), o2, o2.toString()
