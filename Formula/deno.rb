class Deno < Formula
  desc "Command-line JavaScript / TypeScript engine"
  homepage "https://deno.land/"
  url "https://github.com/denoland/deno/releases/download/v0.33.0/deno_src.tar.gz"
  version "0.33.0"
  sha256 "a4e5e9760b10ed3d31b5578f7ab19c63c72886dd142de8d294b20b882c2e502d"

  bottle do
    cellar :any_skip_relocation
    sha256 "b818d4abeb0a0695db49e84958eb367f52d543733e07008daf0d79ed968d0d4e" => :catalina
    sha256 "afc08967f491d60bc8352155c2e44605195a2497e1bd36b6241408c9cca7bf62" => :mojave
    sha256 "75bf2ef45c340220b84bb00a38fb965c23ea68e7c9d8b3219ccd4ee8fa7dd32b" => :high_sierra
  end

  depends_on :macos # Due to Python 2
  depends_on "llvm" => :build if OS.linux? || DevelopmentTools.clang_build_version < 1100
  depends_on "ninja" => :build
  depends_on "rust" => :build
  unless OS.mac?
    depends_on "xz" => :build
    depends_on "python@2"
  end

  depends_on :xcode => ["10.0", :build] if OS.mac? # required by v8 7.9+

  resource "gn" do
    url "https://gn.googlesource.com/gn.git",
      :revision => "a5bcbd726ac7bd342ca6ee3e3a006478fd1f00b5"
  end

  def install
    # Build gn from source (used as a build tool here)
    (buildpath/"gn").install resource("gn")
    cd "gn" do
      system "python", "build/gen.py"
      system "ninja", "-C", "out/", "gn"
    end

    # env args for building a release build with our clang, ninja and gn
    ENV["GN"] = buildpath/"gn/out/gn"
    if OS.linux? || DevelopmentTools.clang_build_version < 1100
      # build with llvm and link against system libc++ (no runtime dep)
      ENV["CLANG_BASE_PATH"] = Formula["llvm"].prefix
      ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib
    else # build with system clang
      ENV["CLANG_BASE_PATH"] = "/usr/"
    end

    unless OS.mac?
      system "core/libdeno/build/linux/sysroot_scripts/install-sysroot.py", "--arch=amd64"
    end

    cd "cli" do
      system "cargo", "install", "-vv", "--locked", "--root", prefix, "--path", "."
    end

    # Install bash and zsh completion
    output = Utils.popen_read("#{bin}/deno completions bash")
    (bash_completion/"deno").write output
    output = Utils.popen_read("#{bin}/deno completions zsh")
    (zsh_completion/"_deno").write output
  end

  test do
    (testpath/"hello.ts").write <<~EOS
      console.log("hello", "deno");
    EOS
    hello = shell_output("#{bin}/deno run hello.ts")
    assert_includes hello, "hello deno"
    cat = shell_output("#{bin}/deno run --allow-read=#{testpath} https://deno.land/std/examples/cat.ts #{testpath}/hello.ts")
    assert_includes cat, "console.log"
  end
end
