class Rust < Formula
  desc "Safe, concurrent, practical language"
  homepage "https://www.rust-lang.org/"
  revision 1

  stable do
    url "https://static.rust-lang.org/dist/rustc-1.41.0-src.tar.gz"
    sha256 "5546822c09944c4d847968e9b7b3d0e299f143f307c00fa40e84a99fabf8d74b"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git",
          :tag      => "0.41.0",
          :revision => "bc8e4c8be13c8f8d1583f9d52e55fda038c0f9d4"
    end
  end

  bottle do
    sha256 "e5aafa87b134aff16659a2b2fb2898cc2ac6b88d1bab32590aa1ab9ed1c8ca8f" => :catalina
    sha256 "f98f829754ade2e0b17cd8ae339c2a5fdf63699ed5f5e8bb92647c152d658312" => :mojave
    sha256 "f8ff3fd81fffd4b2e79f8d5af414f88091d7403cacc91224efaeea68af39c440" => :high_sierra
    sha256 "bce86db974b6844e648f1a3cfd9c993051ac76339329906418b291e2b3024aaf" => :x86_64_linux
  end

  head do
    url "https://github.com/rust-lang/rust.git"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git"
    end
  end

  depends_on "cmake" => :build
  depends_on "python@3.8" => :build
  depends_on "libssh2"
  depends_on "openssl@1.1"
  depends_on "pkg-config"

  uses_from_macos "binutils"
  uses_from_macos "curl"
  uses_from_macos "zlib"

  resource "cargobootstrap" do
    if OS.mac?
      # From https://github.com/rust-lang/rust/blob/#{version}/src/stage0.txt
      url "https://static.rust-lang.org/dist/2019-12-19/cargo-0.41.0-x86_64-apple-darwin.tar.gz"
      sha256 "1ef77a6be5e697bb7dde40854651fc67e91f119d5a9ddf747a25e30c1179fbe1"
    elsif OS.linux?
      # From: https://github.com/rust-lang/rust/blob/#{version}/src/stage0.txt
      url "https://static.rust-lang.org/dist/2019-12-19/cargo-0.41.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "699d5ecc8589211b44858ae164613a1054c0ec000184d0514ea1a0348a483861"
    end
  end

  def install
    ENV.prepend_path "PATH", Formula["python@3.8"].opt_libexec/"bin"

    # Fix build failure for compiler_builtins "error: invalid deployment target
    # for -stdlib=libc++ (requires OS X 10.7 or later)"
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version if OS.mac?

    # Ensure that the `openssl` crate picks up the intended library.
    # https://crates.io/crates/openssl#manual-configuration
    ENV["OPENSSL_DIR"] = Formula["openssl@1.1"].opt_prefix

    # Fix build failure for cmake v0.1.24 "error: internal compiler error:
    # src/librustc/ty/subst.rs:127: impossible case reached" on 10.11, and for
    # libgit2-sys-0.6.12 "fatal error: 'os/availability.h' file not found
    # #include <os/availability.h>" on 10.11 and "SecTrust.h:170:67: error:
    # expected ';' after top level declarator" among other errors on 10.12
    ENV["SDKROOT"] = MacOS.sdk_path if OS.mac?

    args = ["--prefix=#{prefix}"]
    if build.head?
      args << "--disable-rpath"
      args << "--release-channel=nightly"
    else
      args << "--release-channel=stable"
    end
    system "./configure", *args
    system "make"
    system "make", "install"

    resource("cargobootstrap").stage do
      system "./install.sh", "--prefix=#{buildpath}/cargobootstrap"
    end
    ENV.prepend_path "PATH", buildpath/"cargobootstrap/bin"

    resource("cargo").stage do
      ENV["RUSTC"] = bin/"rustc"
      system "cargo", "install", "--root", prefix, "--path", ".", *("--features" if OS.mac?), *("curl-sys/force-system-lib-on-osx" if OS.mac?)
    end

    rm_rf prefix/"lib/rustlib/uninstall.sh"
    rm_rf prefix/"lib/rustlib/install.log"
  end

  def post_install
    Dir["#{lib}/rustlib/**/*.dylib"].each do |dylib|
      chmod 0664, dylib
      MachO::Tools.change_dylib_id(dylib, "@rpath/#{File.basename(dylib)}")
      chmod 0444, dylib
    end
  end

  test do
    system "#{bin}/rustdoc", "-h"
    (testpath/"hello.rs").write <<~EOS
      fn main() {
        println!("Hello World!");
      }
    EOS
    system "#{bin}/rustc", "hello.rs"
    assert_equal "Hello World!\n", `./hello`
    system "#{bin}/cargo", "new", "hello_world", "--bin"
    assert_equal "Hello, world!",
                 (testpath/"hello_world").cd { `#{bin}/cargo run`.split("\n").last }
  end
end
