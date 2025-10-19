import python

/**
 * @name CWE-665: Unsafe Deserialization
 * @description Detects potential unsafe deserialization operations that could lead to CWE-665.
 */
predicate is_unsafe_deserialization(Call call) {
    // Check for common deserialization functions in Python (e.g., pickle.loads)
    let target = call.getTarget()
    (target.getName() = "loads" and target.getQualTypeName() = "pickle.Pickler") or
    (target.getName() = "loads" and target.getQualTypeName() = "yaml.YAMLObject") or
    (target.getName() = "load" and target.getQualTypeName() = "yaml.safe_load") or
    (target.getName() = "read" and target.getQualTypeName() = "marshal.Unpickler")

    // Ensure the input source is potentially untrusted
    exists(StringLiteral sl | call.getArgument(0).is(sl) and 
           (sl.getValue() = "stdin" or 
            sl.getValue() = "request" or 
            sl.getValue() = "input" or 
            sl.getValue() contains "user" or 
            sl.getValue() contains "network"))
}

from Call call
where is_unsafe_deserialization(call)
select call, "Potential unsafe deserialization operation detected (CWE-665)"