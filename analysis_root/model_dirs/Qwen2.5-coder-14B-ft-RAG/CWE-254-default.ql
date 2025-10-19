/**
 * @name CWE CATEGORY: 7PK - Security Features
 * @description nan
 * @kind problem
 * @problem.severity recommendation
 * @id py/default
 */

import python
import semmle.python.ApiGraphs

predicate pamAuth(String module, String function) {
  module = "pam" and
  (
    function = "authenticate"
    or
    function = "is_user_in_group"
    or
    function = "open_session"
    or
    function = "close_session"
    or
    function = "change_password"
  )
}

from Call c, string mod, string func
where
  c.getFunc().(Attribute).getName() = func and
  c.getFunc().(Attribute).getObject().(Name).getId() = mod and
  pamAuth(mod, func)
select c, "Deprecated PAM authorization API: $@.$@", mod, func