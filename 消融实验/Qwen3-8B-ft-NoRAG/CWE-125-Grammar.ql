import py

from Call call
where
    call.getFunction().getName() in (
        "os.path.join",
        "os.system",
        "subprocess.run",
        "subprocess.check_output",
        "open"
    )
    and exists (Parameter param in call.getParameters() |
        param.toString().contains("..")
    )
select call, "Potential Path Traversal vulnerability due to unsafe path handling."