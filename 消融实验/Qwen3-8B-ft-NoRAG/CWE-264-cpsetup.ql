import python

from Call import Call
where Call.getTarget().getName() = "open" and Call.getModule() = "tarfile"
  and Call.getArgument(0).getValue() = "filename"
  and Call.getArgument(0).getOrigin().getKind() = "user"
select Call, "Potential CWE-264: TarSlipQuery vulnerability due to untrusted file extraction."