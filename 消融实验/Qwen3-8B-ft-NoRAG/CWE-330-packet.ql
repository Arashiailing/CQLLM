import python

from FunctionCall import FunctionCall
where FunctionCall.module = "random" and FunctionCall.name in ("randint", "random", "choice", "sample", "getrandbits")
select FunctionCall, "Use of insufficiently random values from the random module, which may be insecure for cryptographic purposes."