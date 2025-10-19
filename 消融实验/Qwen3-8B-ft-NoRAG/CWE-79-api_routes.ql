import py

from CallExpr getParamCall, StringConcat concat, CallExpr responseCall
where getParamCall.getCallee().getName() = "get" and 
      (getParamCall.getArgument(0).getName() = "args" or getParamCall.getArgument(0).getName() = "form" or getParamCall.getArgument(0).getName() = "json")
and concat.getArgument(0) = getParamCall
and responseCall.getCallee().getName() = "response"
select concat, "Potential reflected XSS vulnerability"