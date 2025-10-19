import python

/**
 * @name Unsafe Deserialization Detection
 * @description Detects potential CWE-119 vulnerabilities by identifying deserialization operations without proper validation.
 */
from Call call
where 
    (call.getMethod().getQualifiedName() = "pickle.loads" or 
     call.getMethod().getQualifiedName() = "yaml.load" or 
     call.getMethod().getQualifiedName() = "json.loads" or 
     call.getMethod().getQualifiedName() = "h5py.File" or 
     call.getMethod().getQualifiedName() = "marshal.loads")
select call, "Detected potential unsafe deserialization operation."