/**
 * @name Redundant assignment
 * @description Assigning a variable to itself is useless and very likely indicates an error in the code.
 * @kind problem
 * @tags reliability
 *       useless-code
 *       external/cwe/cwe-563
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-assignment
 */

import python

// 定义一个谓词，用于判断是否为赋值语句，并且左值和右值分别为指定表达式。
predicate assignment(AssignStmt a, Expr left, Expr right) {
  a.getATarget() = left and a.getValue() = right
}

// 定义一个谓词，用于判断两个表达式是否对应。
predicate corresponding(Expr left, Expr right) {
  assignment(_, left, right) // 如果存在一个赋值语句，使得左值和右值为给定的表达式。
  or
  exists(Attribute la, Attribute ra |
    corresponding(la, ra) and // 如果存在对应的属性。
    left = la.getObject() and // 并且左表达式是该属性的对象。
    right = ra.getObject() // 并且右表达式是另一个属性的对象。
  )
}

// 定义一个谓词，用于判断两个表达式是否具有相同的值。
predicate same_value(Expr left, Expr right) {
  same_name(left, right) // 如果两个表达式具有相同的名称。
  or
  same_attribute(left, right) // 或者两个表达式具有相同的属性。
}

// 定义一个谓词，用于判断某个名称是否可能在外部作用域中未定义。
predicate maybe_defined_in_outer_scope(Name n) {
  exists(SsaVariable v | v.getAUse().getNode() = n | v.maybeUndefined()) // 如果存在一个变量使用点，其节点为给定名称，并且可能未定义。
}

/*
 * Protection against FPs in projects that offer compatibility between Python 2 and 3,
 * since many of them make assignments such as
 *
 * if PY2:
 *     bytes = str
 * else:
 *     bytes = bytes
 */

// 定义一个谓词，用于判断一个字符串是否为内建对象的名称。
predicate isBuiltin(string name) { exists(Value v | v = Value::named(name) and v.isBuiltin()) }

// 定义一个谓词，用于判断两个名称是否相同。
predicate same_name(Name n1, Name n2) {
  corresponding(n1, n2) and // 如果两个名称对应。
  n1.getVariable() = n2.getVariable() and // 并且它们指向同一个变量。
  not isBuiltin(n1.getId()) and // 并且第一个名称不是内建对象的名称。
  not maybe_defined_in_outer_scope(n2) // 并且第二个名称不可能在外部作用域中未定义。
}

// 定义一个类值，用于获取属性对象的类型。
ClassValue value_type(Attribute a) { a.getObject().pointsTo().getClass() = result }

// 定义一个谓词，用于判断一个属性是否为属性访问。
predicate is_property_access(Attribute a) {
  value_type(a).lookup(a.getName()) instanceof PropertyValue // 如果属性的类型查找结果是一个属性值实例。
}

// 定义一个谓词，用于判断两个属性是否相同。
predicate same_attribute(Attribute a1, Attribute a2) {
  corresponding(a1, a2) and // 如果两个属性对应。
  a1.getName() = a2.getName() and // 并且它们的名称相同。
  same_value(a1.getObject(), a2.getObject()) and // 并且它们的值相同。
  exists(value_type(a1)) and // 并且第一个属性有类型值。
  not is_property_access(a1) // 并且第一个属性不是属性访问。
}

// 定义一个pragma，用于防止魔法注释影响分析结果。
pragma[nomagic]
Comment pyflakes_comment() { result.getText().toLowerCase().matches("%pyflakes%") } // 如果注释文本包含"pyflakes"（不区分大小写）。

// 定义一个整数函数，用于获取文件中包含Pyflakes注释的行号。
int pyflakes_commented_line(File file) {
  pyflakes_comment().getLocation().hasLocationInfo(file.getAbsolutePath(), result, _, _, _) // 如果Pyflakes注释的位置信息与文件路径匹配，则返回行号。
}

// 定义一个谓词，用于判断一个赋值语句是否被Pyflakes注释标记。
predicate pyflakes_commented(AssignStmt assignment) {
  exists(Location loc |
    assignment.getLocation() = loc and // 如果赋值语句的位置与位置变量匹配。
    loc.getStartLine() = pyflakes_commented_line(loc.getFile()) // 并且位置变量的起始行号是Pyflakes注释的行号。
  )
}

// 定义一个谓词，用于判断左侧表达式是否有副作用。
predicate side_effecting_lhs(Attribute lhs) {
  exists(ClassValue cls, ClassValue decl |
    lhs.getObject().pointsTo().getClass() = cls and // 如果左侧表达式对象的类型是某个类。
    decl = cls.getASuperType() and // 并且该类的某个超类型声明了__setattr__属性。
    not decl.isBuiltin() // 并且该超类型不是内建类型。
  |
    decl.declaresAttribute("__setattr__") // 或者该超类型声明了__setattr__属性。
  )
}

// 查询语句：查找所有自赋值且没有Pyflakes注释且左侧表达式没有副作用的赋值语句。
from AssignStmt a, Expr left, Expr right
where
  assignment(a, left, right) and // 如果是一个赋值语句。
  same_value(left, right) and // 并且左右值相同。
  not pyflakes_commented(a) and // 并且没有被Pyflakes注释标记。
  not side_effecting_lhs(left) // 并且左侧表达式没有副作用。
select a, "This assignment assigns a variable to itself." // 选择这些赋值语句，并报告“此赋值将变量赋值给自身”。
