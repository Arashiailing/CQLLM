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

// 判断赋值语句及其左右操作数
predicate isAssignment(AssignStmt stmt, Expr target, Expr value) {
  stmt.getATarget() = target and stmt.getValue() = value
}

// 递归判断表达式对应关系（包括属性对象）
predicate expressionsCorrespond(Expr left, Expr right) {
  isAssignment(_, left, right)
  or
  exists(Attribute leftAttr, Attribute rightAttr |
    expressionsCorrespond(leftAttr, rightAttr) and
    left = leftAttr.getObject() and
    right = rightAttr.getObject()
  )
}

// 判断表达式是否具有相同值（名称或属性相同）
predicate haveSameValue(Expr left, Expr right) {
  namesIdentical(left, right) or attributesIdentical(left, right)
}

// 检查名称可能在外部作用域未定义
predicate potentiallyUndefinedInOuterScope(Name name) {
  exists(SsaVariable var | var.getAUse().getNode() = name | var.maybeUndefined())
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

// 检查字符串是否为内置对象名称
predicate isBuiltinName(string name) { exists(Value val | val = Value::named(name) and val.isBuiltin()) }

// 判断两个名称是否相同且满足特定条件
predicate namesIdentical(Name name1, Name name2) {
  expressionsCorrespond(name1, name2) and
  name1.getVariable() = name2.getVariable() and
  not isBuiltinName(name1.getId()) and
  not potentiallyUndefinedInOuterScope(name2)
}

// 获取属性对象的类型值
ClassValue attributeValueType(Attribute attr) { attr.getObject().pointsTo().getClass() = result }

// 检查属性是否为属性访问
predicate isPropertyAccess(Attribute attr) {
  attributeValueType(attr).lookup(attr.getName()) instanceof PropertyValue
}

// 判断两个属性是否相同且满足特定条件
predicate attributesIdentical(Attribute attr1, Attribute attr2) {
  expressionsCorrespond(attr1, attr2) and
  attr1.getName() = attr2.getName() and
  haveSameValue(attr1.getObject(), attr2.getObject()) and
  exists(attributeValueType(attr1)) and
  not isPropertyAccess(attr1)
}

// 防止魔法注释干扰分析
pragma[nomagic]
Comment pyflakesMagicComment() { result.getText().toLowerCase().matches("%pyflakes%") }

// 获取包含Pyflakes注释的文件行号
int pyflakesCommentLine(File f) {
  pyflakesMagicComment().getLocation().hasLocationInfo(f.getAbsolutePath(), result, _, _, _)
}

// 检查赋值语句是否被Pyflakes注释标记
predicate isPyflakesCommented(AssignStmt stmt) {
  exists(Location loc |
    stmt.getLocation() = loc and
    loc.getStartLine() = pyflakesCommentLine(loc.getFile())
  )
}

// 检查左侧属性表达式是否有副作用
predicate lhsHasSideEffects(Attribute lhsAttr) {
  exists(ClassValue cls, ClassValue superType |
    lhsAttr.getObject().pointsTo().getClass() = cls and
    superType = cls.getASuperType() and
    not superType.isBuiltin()
  |
    superType.declaresAttribute("__setattr__")
  )
}

// 主查询：查找自赋值且无Pyflakes注释且无副作用的赋值语句
from AssignStmt stmt, Expr target, Expr value
where
  isAssignment(stmt, target, value) and
  haveSameValue(target, value) and
  not isPyflakesCommented(stmt) and
  not lhsHasSideEffects(target)
select stmt, "This assignment assigns a variable to itself."