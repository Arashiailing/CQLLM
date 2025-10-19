/**
 * @deprecated
 * @name Access Control Violations
 * @kind problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/access
 */

import python
import semmle.python.Concepts

from ModuleAccess ma, ModuleAccess::ControlledModule cm, ClassInfo cinfo
where
  cm.isPrivileged() and
  (
    ma.consumes(cm) and not cinfo.canConsumePrivileged(ma)
    or
    ma.consumesAttribute(cm) and not cinfo.canConsumeAttrPrivileged(ma)
  )
select ma.getScope(),
  "Use of module '" + cm.getName() +
      "' violates access control rules for this context, because the " +
      cinfo.getMessageSuffix() + "."