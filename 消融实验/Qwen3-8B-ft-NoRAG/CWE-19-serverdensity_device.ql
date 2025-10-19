import python

from Call call, Argument arg
where call.getCallee().getName() in ("subprocess.call", "subprocess.Popen", "os.system", "subprocess.run")
  and arg.getArgumentIndex() = 0
  and arg.getType().isString()
  and exists(Source source, DataFlow::Path path |
    source.getLocation() = arg.getExpression()
  )
select call, "Potential command injection vulnerability due to untrusted input in command execution."