import py

from CallExpr import CallExpr
from StringConcatExpr import StringConcatExpr
from Variable import Variable

where CallExpr.getFunction().getName() in ("subprocess.run", "os.system", "subprocess.call", "subprocess.Popen")
and (CallExpr.getArgs() has (StringLiteral or Variable) or CallExpr.getArgs() = StringConcatExpr)

select CallExpr, "Potential command injection vulnerability"