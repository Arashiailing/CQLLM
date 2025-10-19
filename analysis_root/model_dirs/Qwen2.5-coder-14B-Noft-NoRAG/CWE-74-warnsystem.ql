import python

from FunctionCall fc, Expr template, Expr userControlledData
where fc.getCallee().getName() = "render" and
      fc.getArgument(0) = template and
      fc.getArgument(1) = userControlledData and
      userControlledData.getType().getName() = "str"
select fc, "Potential Server Side Template Injection vulnerability detected."