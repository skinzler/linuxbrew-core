class Concurrencykit < Formula
  desc "Aid design and implementation of concurrent systems"
  homepage "http://concurrencykit.org"
  url "http://concurrencykit.org/releases/ck-0.6.0.tar.gz"
  mirror "https://github.com/concurrencykit/ck/archive/0.6.0.tar.gz"
  sha256 "d7e27dd0a679e45632951e672f8288228f32310dfed2d5855e9573a9cf0d62df"
  head "https://github.com/concurrencykit/ck.git"

  bottle do
    cellar :any
    sha256 "5f9f70680563a29f6575b2dd64e6d6b9f84d31d207a9c96af2d5e38ae69a289f" => :catalina
    sha256 "d219f60638ce9501978e8494b64eef8861685f78c9e3eeefa295043a05ba75a2" => :mojave
    sha256 "4bb00e2cc25ebe7e103ca8923c3376e86b3b7b360fc73beb8078d15af1239571" => :high_sierra
    sha256 "1597c3fde162ccc3c8c729003da472f3f414509b18a2e64a1fade268ee8798e0" => :sierra
    sha256 "897667302b03467c291ff141082b21ec2f31fc82ef5940f791196a14cec24909" => :el_capitan
    sha256 "914d6e5afd3412f8892770f73233e1cca915b2a2315c811fc6a8d6fa5ab811ce" => :yosemite
    sha256 "8c2629ba4c2b3985a0093ecae71bf9bed44bb4806f28f0c3b6c3c47bc894e1ef" => :x86_64_linux
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <ck_spinlock.h>
      int main()
      {
          return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lck",
           testpath/"test.c", "-o", testpath/"test"
    system "./test"
  end
end
