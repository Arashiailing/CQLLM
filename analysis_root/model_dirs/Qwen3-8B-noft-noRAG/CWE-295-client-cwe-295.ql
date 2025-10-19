import python

/**
 * @name CWE-295: Improper Certificate Validation
 * @description Detects logging of sensitive certificate data in plaintext
 */
from CalledMethod call, Argument arg
where 
  (call.name = "logging.info" or 
   call.name = "logging.debug" or 
   call.name = "print") and
  arg.value has type("ssl.SSLCert") or
  arg.value has type("socket._sslobj") or
  arg.value has type("urllib3.connection.VerifiedHTTPSConnection") or
  arg.value has type("http.client.HTTPSConnection")
select call, "Potential cleartext logging of certificate information detected"