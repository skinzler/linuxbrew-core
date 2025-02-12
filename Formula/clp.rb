class Clp < Formula
  desc "Linear programming solver"
  homepage "https://github.com/coin-or/Clp"
  url "https://github.com/coin-or/Clp/archive/releases/1.17.5.tar.gz"
  sha256 "7e2856ef7cab4bc1a439756cf101d5184a7af09d2921452a22a459ac8f949b7b"

  bottle do
    cellar :any
    sha256 "d1a33cab0f8dcf831ac90298ed32f654c421c050cdd896ae1fb668b918c3a2de" => :catalina
    sha256 "289e8a0a562e795ef4c88395ea41098d62965f474249839bd53c8aa7f14f4ef8" => :mojave
    sha256 "26e2a26ff6c1212ca867fd41bfb827969e414e540b5bbe2f28a034ea9e32293b" => :high_sierra
    sha256 "1814617d6733a59773a256cfd525df78bc4a21733dee350212c474a2b92989a8" => :x86_64_linux
  end

  depends_on "pkg-config" => [:build, :test]
  depends_on "coinutils"
  depends_on "openblas"

  resource "coin-or-tools-data-sample-p0033-mps" do
    url "https://raw.githubusercontent.com/coin-or-tools/Data-Sample/releases/1.2.11/p0033.mps"
    sha256 "8ccff819023237c79ef32e238a5da9348725ce9a4425d48888baf3a0b3b42628"
  end

  def install
    # Work around https://github.com/coin-or/Clp/issues/109:
    # Error 1: "mkdir: #{include}/clp/coin: File exists."
    mkdir include/"clp/coin"

    args = [
      "--datadir=#{pkgshare}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--includedir=#{include}/clp",
      "--prefix=#{prefix}",
      "--with-blas-incdir=#{Formula["openblas"].opt_include}",
      "--with-blas-lib=-L#{Formula["openblas"].opt_lib} -lopenblas",
      "--with-lapack-incdir=#{Formula["openblas"].opt_include}",
      "--with-lapack-lib=-L#{Formula["openblas"].opt_lib} -lopenblas",
    ]
    system "./configure", *args
    system "make", "install"
  end

  test do
    resource("coin-or-tools-data-sample-p0033-mps").stage testpath
    system bin/"clp", "-import", testpath/"p0033.mps", "-primals"
    (testpath/"test.cpp").write <<~EOS
      #include <ClpSimplex.hpp>
      int main() {
        ClpSimplex model;
        int status = model.readMps("#{testpath}/p0033.mps", true);
        if (status != 0) { return status; }
        status = model.primal();
        return status;
      }
    EOS
    pkg_config_flags = `pkg-config --cflags --libs clp`.chomp.split
    system ENV.cxx, "test.cpp", *pkg_config_flags
    system "./a.out"
  end
end
