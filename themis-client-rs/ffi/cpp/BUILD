cc_library(
    name = "ffi",
    srcs = ["ffi.cc", "../main.cc"],
    visibility = ["//visibility:public"],
    deps = [
        ":include",
        "//demo-rs:include",
    ],
)

cc_library(
    name = "include",
    hdrs = ["header.h"],
    visibility = ["//visibility:public"],
    deps = ["//:core"],
)
