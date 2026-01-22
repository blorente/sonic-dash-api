
load("@bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory_bin_action")

def _to_install_dir_impl(ctx):
  all_headers = ctx.attr._cc_proto_target[CcInfo].compilation_context.direct_public_headers
  headers_to_move = [
    f for f in all_headers if "_virtual_includes" in f.dirname and f.path.endswith(".pb.h")
  ]
  includes = ctx.attr._cc_proto_target[CcInfo].compilation_context.includes
  copy_bin = ctx.toolchains["@bazel_lib//lib:copy_to_directory_toolchain_type"].copy_to_directory_info.bin

  dst = ctx.actions.declare_directory(ctx.attr._install_dir)

  copy_to_directory_bin_action(
    ctx,
    name = ctx.attr.name,
    dst = dst,
    copy_to_directory_bin	= copy_bin,
    files = headers_to_move,
    root_paths = ["_virtual_includes/proto"],
  )

  return [
      DefaultInfo(
          files = depset([dst]),
          runfiles = ctx.runfiles([dst]),
      ),
  ]

to_install_dir = rule(
  implementation = _to_install_dir_impl,
  doc = "A rule that extracts all the pb.h headers from a CcInfo and puts them in an appropriately-named directory",
  attrs = {
    "_cc_proto_target": attr.label(
      providers = [CcInfo],
      default = "//:dashapi_proto",
    ),
    "_install_dir": attr.string(
      default = "dash_api",
    ),
  },
  toolchains = ["@bazel_lib//lib:copy_to_directory_toolchain_type"],
)
