import python

from Call call, StringLiteralConcatenation concats
where call.getCallee().getName() in ["run", "call", "check_output"] and
      call.getArgument(0).isString() and
      concats.getConcatenatedStrings().size() > 1
select call, "Unsafe shell command construction via string concatenation in arguments."