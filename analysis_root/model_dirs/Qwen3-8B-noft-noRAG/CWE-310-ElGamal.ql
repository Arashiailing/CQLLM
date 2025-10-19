import python

/**
 * @name WeakSensitiveDataHashing
 * @description Detects the use of weak hash functions on sensitive data.
 */
from Call call, Method m
where m.hasName("md5") or m.hasName("sha1")
  and m.isMemberOf(Module.new("hashlib"))
  and call.getCallee() = m
  and call.getArguments().exists(arg |
    arg.toString() =~ /password|secret|key|token|cred/i
    or arg.isStringLiteral()
  )
select call, "Weak hash function used on sensitive data."