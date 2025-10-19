/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind problem
 * @id py/stringutils
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags external/cwe/cwe-400
 */

import python
import semmle.python.regex

predicate contains_dotstar(StringLiteral lit) {
  exists(lit.getText().regexpMatch("(?i).*\\.(?:(?:[a-z]+)|\\*)+.*"))
}

predicate re_findall_arg1(Ssa::CallNode re_call, StringLiteral arg1) {
  re_call = API::moduleImport("re").getMember("findall").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
}

predicate re_findall_arg2(Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2) {
  re_call = API::moduleImport("re").getMember("findall").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
  and
  arg2 = re_call.getArg(1)
}

predicate re_search_arg1(Ssa::CallNode re_call, StringLiteral arg1) {
  re_call = API::moduleImport("re").getMember("search").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
}

predicate re_search_arg2(Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2) {
  re_call = API::moduleImport("re").getMember("search").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
  and
  arg2 = re_call.getArg(1)
}

predicate re_match_arg1(Ssa::CallNode re_call, StringLiteral arg1) {
  re_call = API::moduleImport("re").getMember("match").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
}

predicate re_match_arg2(Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2) {
  re_call = API::moduleImport("re").getMember("match").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
  and
  arg2 = re_call.getArg(1)
}

predicate re_split_arg1(Ssa::CallNode re_call, StringLiteral arg1) {
  re_call = API::moduleImport("re").getMember("split").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
}

predicate re_split_arg2(Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2) {
  re_call = API::moduleImport("re").getMember("split").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
  and
  arg2 = re_call.getArg(1)
}

predicate re_subn_arg1(Ssa::CallNode re_call, StringLiteral arg1) {
  re_call = API::moduleImport("re").getMember("subn").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
}

predicate re_subn_arg2(Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2) {
  re_call = API::moduleImport("re").getMember("subn").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
  and
  arg2 = re_call.getArg(1)
}

predicate re_subn_arg3(Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2, StringLiteral arg3) {
  re_call = API::moduleImport("re").getMember("subn").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
  and
  arg2 = re_call.getArg(1)
  and
  arg3 = re_call.getArg(2)
}

predicate re_sub_arg1(Ssa::CallNode re_call, StringLiteral arg1) {
  re_call = API::moduleImport("re").getMember("sub").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
}

predicate re_sub_arg2(Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2) {
  re_call = API::moduleImport("re").getMember("sub").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
  and
  arg2 = re_call.getArg(1)
}

predicate re_sub_arg3(Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2, StringLiteral arg3) {
  re_call = API::moduleImport("re").getMember("sub").getACall().getNode()
  and
  arg1 = re_call.getArg(0)
  and
  arg2 = re_call.getArg(1)
  and
  arg3 = re_call.getArg(2)
}

from Ssa::CallNode re_call, StringLiteral arg1, StringLiteral arg2
where
  re_findall_arg1(re_call, arg1) and
  arg1.isInStringLiteral(arg2)
  or
  re_findall_arg2(re_call, arg1, arg2) and
  arg1.isInStringLiteral(arg2)
  or
  re_search_arg1(re_call, arg1) and
  arg1.isInStringLiteral(arg2)
  or
  re_search_arg2(re_call, arg1, arg2) and
  arg1.isInStringLiteral(arg2)
  or
  re_match_arg1(re_call, arg1) and
  arg1.isInStringLiteral(arg2)
  or
  re_match_arg2(re_call, arg1, arg2) and
  arg1.isInStringLiteral(arg2)
  or
  re_split_arg1(re_call, arg1) and
  arg1.isInStringLiteral(arg2)
  or
  re_split_arg2(re_call, arg1, arg2) and
  arg1.isInStringLiteral(arg2)
  or
  re_subn_arg1(re_call, arg1) and
  arg1.isInStringLiteral(arg2)
  or
  re_subn_arg2(re_call, arg1, arg2) and
  arg1.isInStringLiteral(arg2)
  or
  re_subn_arg3(re_call, arg1, arg2, arg2) and
  arg1.isInStringLiteral(arg2)
  or
  re_sub_arg1(re_call, arg1) and
  arg1.isInStringLiteral(arg2)
  or
  re_sub_arg2(re_call, arg1, arg2) and
  arg1.isInStringLiteral(arg2)
  or
  re_sub_arg3(re_call, arg1, arg2, arg2) and
  arg1.isInStringLiteral(arg2)
select re_call.asExpr(), "Call to " + re_call.asExpr().(CallNode).getName() + " depends on $@.", arg2,
  "string literal"