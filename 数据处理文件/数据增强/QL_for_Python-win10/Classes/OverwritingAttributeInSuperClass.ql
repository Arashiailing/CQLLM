/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Assignment to self attribute overwrites attribute previously defined in subclass or superclass `__init__` method.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision medium
 * @id py/overwritten-inherited-attribute
 */

import python

// 定义一个类 InitCallStmt，继承自 ExprStmt
class InitCallStmt extends ExprStmt {
  // 构造函数，检查当前表达式语句是否是一个对 __init__ 方法的调用
  InitCallStmt() {
    exists(Call call, Attribute attr | call = this.getValue() and attr = call.getFunc() |
      attr.getName() = "__init__"
    )
  }
}

// 谓词函数，判断在子类的初始化函数中是否覆盖了父类或子类的属性
predicate overwrites_which(Function subinit, AssignStmt write_attr, string which) {
  // 确保赋值语句的作用域是子类的初始化函数
  write_attr.getScope() = subinit and
  // 确保赋值语句是对 self 属性的写操作
  self_write_stmt(write_attr, _) and
  // 查找赋值语句所在的作用域范围
  exists(Stmt top | top.contains(write_attr) or top = write_attr |
    (
      // 如果赋值语句在 __init__ 调用之后，则认为是覆盖了父类的属性
      exists(int i, int j, InitCallStmt call | call.getScope() = subinit |
        i > j and top = subinit.getStmt(i) and call = subinit.getStmt(j) and which = "superclass"
      )
      or
      // 如果赋值语句在 __init__ 调用之前，则认为是覆盖了子类的属性
      exists(int i, int j, InitCallStmt call | call.getScope() = subinit |
        i < j and top = subinit.getStmt(i) and call = subinit.getStmt(j) and which = "subclass"
      )
    )
  )
}

// 谓词函数，判断给定的语句是否是对 self 属性的写操作
predicate self_write_stmt(Stmt s, string attr) {
  exists(Attribute a, Name self |
    self = a.getObject() and
    s.contains(a) and
    self.getId() = "self" and
    a.getCtx() instanceof Store and
    a.getName() = attr
  )
}

// 谓词函数，判断两个函数中的语句是否都对同一个属性进行了赋值操作
predicate both_assign_attribute(Stmt s1, Stmt s2, Function f1, Function f2) {
  exists(string name |
    s1.getScope() = f1 and
    s2.getScope() = f2 and
    self_write_stmt(s1, name) and
    self_write_stmt(s2, name)
  )
}

// 谓词函数，判断是否存在属性覆盖的情况
predicate attribute_overwritten(
  AssignStmt overwrites, AssignStmt overwritten, string name, string classtype, string classname
) {
  exists(
    FunctionObject superinit, FunctionObject subinit, ClassObject superclass, ClassObject subclass,
    AssignStmt subattr, AssignStmt superattr
  |
    (
      // 如果是覆盖父类的属性
      classtype = "superclass" and
      classname = superclass.getName() and
      overwrites = subattr and
      overwritten = superattr
      or
      // 如果是覆盖子类的属性
      classtype = "subclass" and
      classname = subclass.getName() and
      overwrites = superattr and
      overwritten = subattr
    ) and
    /* OK if overwritten in subclass and is a class attribute */
    // 如果被覆盖的属性不是在父类中声明的，或者覆盖发生在子类中，则认为是合法的
    (not exists(superclass.declaredAttribute(name)) or classtype = "subclass") and
    // 确保父类和子类都有 __init__ 方法
    superclass.declaredAttribute("__init__") = superinit and
    subclass.declaredAttribute("__init__") = subinit and
    // 确保子类是父类的子类
    superclass = subclass.getASuperType() and
    // 确保覆盖发生在正确的位置
    overwrites_which(subinit.getFunction(), subattr, classtype) and
    // 确保两个函数都对同一个属性进行了赋值操作
    both_assign_attribute(subattr, superattr, subinit.getFunction(), superinit.getFunction()) and
    // 确保被覆盖的属性是对 self 属性的写操作
    self_write_stmt(superattr, name)
  )
}

// 查询语句，查找所有属性覆盖的情况并输出相关信息
from string classtype, AssignStmt overwrites, AssignStmt overwritten, string name, string classname
where attribute_overwritten(overwrites, overwritten, name, classtype, classname)
select overwrites,
  "Assignment overwrites attribute " + name + ", which was previously defined in " + classtype +
    " $@.", overwritten, classname
