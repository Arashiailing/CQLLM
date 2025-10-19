import python

from Call call
where call.getMethod().getName() = "verify"
  and call.getMethod().getQualifiedName() = "hashlib.hmac.verify"
  or call.getMethod().getQualifiedName() = "cryptography.hazmat.primitives.asymmetric.rsa.RSAPrivateKey.verify"
  or call.getMethod().getQualifiedName() = "cryptography.hazmat.primitives.asymmetric.dsa.DSAPrivateKey.verify"
select call, "Improper verification of cryptographic signature"