# dirty implementation as example of ts_library created by @mprobst
TypeScriptInfo = provider(fields = ["dts", "js"])

_TOOLS = {
    "_node": attr.label(
        default = Label("@nodejs//:node"),
        allow_files = True,
        executable = True,
        cfg = "host",
        single_file = True,
    ),
    "_tsc": attr.label(
        cfg = "host",
        allow_files = True,
        single_file = True,
        default = Label("//:node_modules/typescript/lib/tsc.js"),
    ),
}

def _outfile(ctx, s, ext):
    return ctx.actions.declare_file(s.short_path.replace(".ts", ext))

def _ts_library_impl(ctx):
    js = [_outfile(ctx, s, ".js")
            for s in ctx.files.srcs]
    dts = [_outfile(ctx, s, ".d.ts")
            for s in ctx.files.srcs]

    deps_js = [dep[TypeScriptInfo].js
                for dep in ctx.attr.deps]
    deps_dts = [dep[TypeScriptInfo].dts
                for dep in ctx.attr.deps]

    inputs = depset(ctx.files.srcs, transitive = deps_dts)
    outputs = js + dts

    cfg = ctx.actions.declare_file(ctx.label.name + "_tsconfig.json")

    to_root = len(cfg.dirname.split("/")) * "../"
    ctx.actions.write(
        cfg,
        content="""{{
    "compilerOptions": {{
        "baseUrl": "{baseDir}",
        "rootDirs": [
            "{baseDir}",
            "{baseDir}{genDir}",
            "{baseDir}{binDir}"
        ],
        "declaration": true,
        "outDir": "." }},
        "files": {files}
    }}
            """.format(
                baseDir=to_root,
                genDir=ctx.bin_dir.path,
                binDir=ctx.genfiles_dir.path,
                files=[to_root + f.path for f in inputs]))

    ctx.actions.run(
        executable = ctx.executable._node,
        tools = ctx.files._tsc,
        progress_message = "Compiling TypeScript",
        inputs = inputs + [cfg],
        outputs = outputs,
        arguments = [
            ctx.file._tsc.path,
            "--project",
            cfg.path,
        ],
    )

    return [
        DefaultInfo(files = depset(js + dts)),
        TypeScriptInfo(
            dts = depset(dts, transitive = deps_dts),
            js = depset(js, transitive = deps_js),
        ),
    ]

ts_library = rule(
    implementation = _ts_library_impl,
    attrs = dict({
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
    }.items() + _TOOLS.items()),
)
