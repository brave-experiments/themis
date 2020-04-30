fn main() {
    cxx::Build::new()
        .bridge("src/main.rs")
        .file("cpp/ffi.cc")
        //.file("main.cc")
        .flag("-std=c++11")
        .compile("ffi-cxx");

    println!("cargo:rerun-if-changed=src/main.rs");
    println!("cargo:rerun-if-changed=.cpp/header.h");
    println!("cargo:rerun-if-changed=cpp/ffi.cc");
}
