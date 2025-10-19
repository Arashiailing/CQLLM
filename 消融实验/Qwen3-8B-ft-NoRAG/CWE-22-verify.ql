import py

from Call call, StringLiteral s1, StringLiteral s2
where call.getTarget() = "os.path.join" and call.getArgs() = [s1, s2]
and (s1.getString() + s2.getString()) contains "../"
select call, "Potential path traversal via os.path.join with untrusted input"