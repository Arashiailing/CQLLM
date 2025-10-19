/**
 * @name Consistency check
 * @description General consistency check to be run on any and all code. Should never produce any results.
 * @id py/consistency-check
 */

import python
import analysis.DefinitionTracking

// 定义一个谓词 uniqueness_error，用于检查唯一性错误。
predicate uniqueness_error(int number, string what, string problem) {
  // 检查 'what' 是否在指定的字符串列表中。
  what in [
      "toString", "getLocation", "getNode", "getDefinition", "getEntryNode", "getOrigin",
      "getAnInferredType"
    ] and
  // 检查 'number' 是否符合条件，并设置相应的问题描述。
  (
    number = 0 and problem = "no results for " + what + "()"
    or
    number in [2 .. 10] and problem = number.toString() + " results for " + what + "()"
  )
}

// 定义一个谓词 ast_consistency，用于检查抽象语法树的一致性。
predicate ast_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 AstNode。
  exists(AstNode a | clsname = a.getAQlClass() |
    // 检查 toString 方法的唯一性错误。
    uniqueness_error(count(a.toString()), "toString", problem) and
    what = "at " + a.getLocation().toString()
    or
    // 检查 getLocation 方法的唯一性错误。
    uniqueness_error(strictcount(a.getLocation()), "getLocation", problem) and
    what = a.getLocation().toString()
    or
    // 检查是否存在位置，并且不是包模块。
    not exists(a.getLocation()) and
    not a.(Module).isPackage() and
    problem = "no location" and
    what = a.toString()
  )
}

// 定义一个谓词 location_consistency，用于检查位置的一致性。
predicate location_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 Location。
  exists(Location l | clsname = l.getAQlClass() |
    // 检查 toString 方法的唯一性错误。
    uniqueness_error(count(l.toString()), "toString", problem) and what = "at " + l.toString()
    or
    // 检查是否存在 toString 方法。
    not exists(l.toString()) and
    problem = "no toString" and
    (
      exists(AstNode thing | thing.getLocation() = l |
        what = "a location of a " + thing.getAQlClass()
      )
      or
      not exists(AstNode thing | thing.getLocation() = l) and
      what = "a location"
    )
    or
    // 检查结束行号是否小于起始行号。
    l.getEndLine() < l.getStartLine() and
    problem = "end line before start line" and
    what = "at " + l.toString()
    or
    // 检查结束列号是否小于起始列号。
    l.getEndLine() = l.getStartLine() and
    l.getEndColumn() < l.getStartColumn() and
    problem = "end column before start column" and
    what = "at " + l.toString()
  )
}

// 定义一个谓词 cfg_consistency，用于检查控制流图的一致性。
predicate cfg_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 ControlFlowNode。
  exists(ControlFlowNode f | clsname = f.getAQlClass() |
    // 检查 getNode 方法的唯一性错误。
    uniqueness_error(count(f.getNode()), "getNode", problem) and
    what = "at " + f.getLocation().toString()
    or
    // 检查是否存在位置。
    not exists(f.getLocation()) and
    not exists(Module p | p.isPackage() | p.getEntryNode() = f or p.getAnExitNode() = f) and
    problem = "no location" and
    what = f.toString()
    or
    // 检查 getValue 方法的唯一性错误。
    uniqueness_error(count(f.(AttrNode).getObject()), "getValue", problem) and
    what = "at " + f.getLocation().toString()
  )
}

// 定义一个谓词 scope_consistency，用于检查作用域的一致性。
predicate scope_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 Scope。
  exists(Scope s | clsname = s.getAQlClass() |
    // 检查 getEntryNode 方法的唯一性错误。
    uniqueness_error(count(s.getEntryNode()), "getEntryNode", problem) and
    what = "at " + s.getLocation().toString()
    or
    // 检查 toString 方法的唯一性错误。
    uniqueness_error(count(s.toString()), "toString", problem) and
    what = "at " + s.getLocation().toString()
    or
    // 检查 getLocation 方法的唯一性错误。
    uniqueness_error(strictcount(s.getLocation()), "getLocation", problem) and
    what = "at " + s.getLocation().toString()
    or
    // 检查是否存在位置，并且不是包模块。
    not exists(s.getLocation()) and
    problem = "no location" and
    what = s.toString() and
    not s.(Module).isPackage()
  )
}

// 返回内建对象的最佳描述。
string best_description_builtin_object(Object o) {
  o.isBuiltin() and
  (
    result = o.toString()
    or
    not exists(o.toString()) and py_cobjectnames(o, result)
    or
    not exists(o.toString()) and
    not py_cobjectnames(o, _) and
    result = "builtin object of type " + o.getAnInferredType().toString()
    or
    not exists(o.toString()) and
    not py_cobjectnames(o, _) and
    not exists(o.getAnInferredType().toString()) and
    result = "builtin object"
  )
}

// 私有谓词，用于检查内省的内建对象。
private predicate introspected_builtin_object(Object o) {
  /*
   * Only check objects from the extractor, missing data for objects generated from C source code analysis is OK.
   * as it will be ignored if it doesn't match up with the introspected form.
   */

  py_cobject_sources(o, 0)
}

// 定义一个谓词 builtin_object_consistency，用于检查内建对象的一致性。
predicate builtin_object_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 Object。
  exists(Object o |
    clsname = o.getAQlClass() and
    what = best_description_builtin_object(o) and
    introspected_builtin_object(o)
  |
    // 检查是否存在推断类型和名称。
    not exists(o.getAnInferredType()) and
    not py_cobjectnames(o, _) and
    problem = "neither name nor type"
    or
    // 检查名称的唯一性错误。
    uniqueness_error(count(string name | py_cobjectnames(o, name)), "name", problem)
    or
    not exists(o.getAnInferredType()) and problem = "no results for getAnInferredType"
    or
    not exists(o.toString()) and
    problem = "no toString" and
    not exists(string name | name.matches("\\_semmle%") | py_special_objects(o, name)) and
    not o = unknownValue()
  )
}

// 定义一个谓词 source_object_consistency，用于检查源对象的一致性。
predicate source_object_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 Object。
  exists(Object o | clsname = o.getAQlClass() and not o.isBuiltin() |
    // 检查 getOrigin 方法的唯一性错误。
    uniqueness_error(count(o.getOrigin()), "getOrigin", problem) and
    what = "at " + o.getOrigin().getLocation().toString()
    or
    // 检查是否存在位置。
    not exists(o.getOrigin().getLocation()) and problem = "no location" and what = "??"
    or
    not exists(o.toString()) and
    problem = "no toString" and
    what = "at " + o.getOrigin().getLocation().toString()
    or
    // 检查 toString 方法的多重性错误。
    strictcount(o.toString()) > 1 and problem = "multiple toStrings()" and what = o.toString()
  )
}

// 定义一个谓词 ssa_consistency，用于检查静态单赋值形式的一致性。
predicate ssa_consistency(string clsname, string problem, string what) {
  /* Zero or one definitions of each SSA variable */
  // 检查是否存在满足条件的 SsaVariable。
  exists(SsaVariable var | clsname = var.getAQlClass() |
    // 检查 getDefinition 方法的唯一性错误。
    uniqueness_error(strictcount(var.getDefinition()), "getDefinition", problem) and
    what = var.getId()
  )
  or
  /* Dominance criterion: Definition *must* dominate *all* uses. */
  // 检查是否存在满足条件的 SsaVariable 和 ControlFlowNode。
  exists(SsaVariable var, ControlFlowNode defn, ControlFlowNode use |
    defn = var.getDefinition() and use = var.getAUse()
  |
    // 检查定义是否支配使用。
    not defn.strictlyDominates(use) and
    not defn = use and
    /* Phi nodes which share a flow node with a use come *before* the use */
    not (exists(var.getAPhiInput()) and defn = use) and
    clsname = var.getAQlClass() and
    problem = "a definition which does not dominate a use at " + use.getLocation() and
    what = var.getId() + " at " + var.getLocation()
  )
  or
  /* Minimality of phi nodes */
  // 检查是否存在满足条件的 SsaVariable。
  exists(SsaVariable var |
    strictcount(var.getAPhiInput()) = 1 and
    var.getAPhiInput()
        .getDefinition()
        .getBasicBlock()
        .strictlyDominates(var.getDefinition().getBasicBlock())
  |
    clsname = var.getAQlClass() and
    problem = " a definition which is dominated by the definition of an incoming phi edge." and
    what = var.getId() + " at " + var.getLocation()
  )
}

// 定义一个谓词 function_object_consistency，用于检查函数对象的一致性。
predicate function_object_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 FunctionObject。
  exists(FunctionObject func | clsname = func.getAQlClass() |
    what = func.getName() and
    (
      // 检查 descriptiveString 方法的存在性。
      not exists(func.descriptiveString()) and problem = "no descriptiveString()"
      or
      exists(int c | c = strictcount(func.descriptiveString()) and c > 1 |
        problem = c + "descriptiveString()s"
      )
    )
    or
    not exists(func.getName()) and what = "?" and problem = "no name"
  )
}

// 定义一个谓词 multiple_origins_per_object，用于检查每个对象的多个起源。
predicate multiple_origins_per_object(Object obj) {
  not obj.isC() and
  not obj instanceof ModuleObject and
  // 检查是否存在多个引用。
  exists(ControlFlowNode use, Context ctx |
    strictcount(ControlFlowNode orig | use.refersTo(ctx, obj, _, orig)) > 1
  )
}

// 定义一个谓词 intermediate_origins，用于检查中间起源。
predicate intermediate_origins(ControlFlowNode use, ControlFlowNode inter, Object obj) {
  // 检查是否存在满足条件的 ControlFlowNode。
  exists(ControlFlowNode orig, Context ctx | not inter = orig |
    use.refersTo(ctx, obj, _, inter) and
    inter.refersTo(ctx, obj, _, orig) and
    // It can sometimes happen that two different modules (e.g. cPickle and Pickle)
    // have the same attribute, but different origins.
    not strictcount(Object val | inter.(AttrNode).getObject().refersTo(val)) > 1
  )
}

// 定义一个谓词 points_to_consistency，用于检查指向的一致性。
predicate points_to_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 Object。
  exists(Object obj |
    multiple_origins_per_object(obj) and
    clsname = obj.getAQlClass() and
    problem = "multiple origins for an object" and
    what = obj.toString()
  )
  or
  // 检查是否存在满足条件的 ControlFlowNode。
  exists(ControlFlowNode use, ControlFlowNode inter |
    intermediate_origins(use, inter, _) and
    clsname = use.getAQlClass() and
    problem = "has intermediate origin " + inter and
    what = use.toString()
  )
}

// 定义一个谓词 jump_to_definition_consistency，用于检查跳转到定义的一致性。
predicate jump_to_definition_consistency(string clsname, string problem, string what) {
  problem = "multiple (jump-to) definitions" and
  // 检查是否存在满足条件的 Expr。
  exists(Expr use |
    strictcount(getUniqueDefinition(use)) > 1 and
    clsname = use.getAQlClass() and
    what = use.toString()
  )
}

// 定义一个谓词 file_consistency，用于检查文件的一致性。
predicate file_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 File 和 Folder。
  exists(File file, Folder folder |
    clsname = file.getAQlClass() and
    problem = "has same name as a folder" and
    what = file.getAbsolutePath() and
    what = folder.getAbsolutePath()
  )
  or
  // 检查是否存在满足条件的 Container。
  exists(Container f |
    clsname = f.getAQlClass() and
    uniqueness_error(count(f.toString()), "toString", problem) and
    what = "file " + f.getAbsolutePath()
  )
}

// 定义一个谓词 class_value_consistency，用于检查类值的一致性。
predicate class_value_consistency(string clsname, string problem, string what) {
  // 检查是否存在满足条件的 ClassValue。
  exists(ClassValue value, ClassValue sup, string attr |
    what = value.getName() and
    sup = value.getASuperType() and
    exists(sup.lookup(attr)) and
    not value.failedInference(_) and
    not exists(value.lookup(attr)) and
    clsname = value.getAQlClass() and
    problem = "no attribute '" + attr + "', but super type '" + sup.getName() + "' does."
  )
}

// 从指定的关系中选择数据，并生成结果。
from string clsname, string problem, string what
where
  ast_consistency(clsname, problem, what) or         // AST一致性检查。
  location_consistency(clsname, problem, what) or    // 位置一致性检查。
  scope_consistency(clsname, problem, what) or       // 作用域一致性检查。
  cfg_consistency(clsname, problem, what) or         // 控制流图一致性检查。
  ssa_consistency(clsname, problem, what) or        // SSA一致性检查。
  builtin_object_consistency(clsname, problem, what) or // 内建对象一致性检查。
  source_object_consistency(clsname, problem, what) or // 源对象一致性检查。
  function_object_consistency(clsname, problem, what) or // 函数对象一致性检查。
  points_to_consistency(clsname, problem, what) or // 指向一致性检查。
  jump_to_definition_consistency(clsname, problem, what) or // 跳转到定义一致性检查。
  file_consistency(clsname, problem, what) or       // 文件一致性检查。
  class_value_consistency(clsname, problem, what)    // 类值一致性检查。
select clsname + " " + what + " has " + problem       // 选择并生成结果。
