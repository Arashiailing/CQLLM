import python

/**
 * Detects usage of weak hashing algorithms (e.g., MD5, SHA-1) on sensitive data.
 */
predicate isWeakHashFunction(Function function) {
  let name = function.getName()
  (name = "md5" or name = "sha1" or name = "sha" or name = "ripemd160")
}

from Call call, Function function
where 
  call.getBase().isMemberOf(python.importedModule("hashlib")) 
  and function = call.getMethod()
  and isWeakHashFunction(function)
  and exists(Argument arg | arg.getParentCall() = call and arg.getType().isString())
select call, "Weak hashing algorithm used on sensitive data."