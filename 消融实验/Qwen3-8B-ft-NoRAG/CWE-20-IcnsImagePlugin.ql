import py

from CallExpr call
where call.getFunction().getName() = "os.path.join"
select call, "Potential Path Injection due to lack of input validation"