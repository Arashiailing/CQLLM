import python

from CallExpr call
where 
    call.getKind() = "FStringCall" 
    or call.getMethodName() = "format" 
    or call.getOperator() = "+"
    and exists(VarDef vd | vd.getVariable().getName() = "user_input" and call.getArgument(0).getValue() = vd.getValue())
select call, "Reflected XSS: User input directly inserted into HTML string without escaping."