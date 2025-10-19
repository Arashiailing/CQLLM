import python

/** @name TarSlipQuery (CWE-264) */
/**
 * Detects potential TarSlipQuery vulnerabilities where untrusted archive files can be used to overwrite or execute malicious code through path traversal.
 * This query looks for cases where the `tarfile` module is used without validating or restricting the extraction path.
 */

from methodCall mc
where 
    mc.getMethodName() = "tarfile.open" or 
    mc.getMethodName() = "shutil.unpack_archive"
select mc, "Potential TarSlipQuery vulnerability: Untrusted tar file being processed without proper path validation."