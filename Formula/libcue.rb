class Libcue < Formula
  desc "Cue sheet parser library for C"
  homepage "https://github.com/lipnitsk/libcue"
  url "https://github.com/lipnitsk/libcue/archive/v2.2.1.tar.gz"
  sha256 "f27bc3ebb2e892cd9d32a7bee6d84576a60f955f29f748b9b487b173712f1200"

  bottle do
    cellar :any
    sha256 "17252ea3af3c3a75478e8526ae7856dadfa641d7eb050553503bfe383573e740" => :catalina
    sha256 "e3f6c16d235459f97b299627d359cb9fbe7526b8635e08521b1c36460b045162" => :mojave
    sha256 "209e548399503830e0f786c6faef21836aa350d67db644b9ad291703ebe2e9c5" => :high_sierra
    sha256 "14a6edb39d2887ad6beeb34dad944501d01f70480a529cb7e50d838833404f4f" => :sierra
    sha256 "27f8ab5419958ea5817e5e44b68f24ea2a0c27d12a664556b12f6789866d0da5" => :el_capitan
    sha256 "c06e978e72a9220195abe2ee63b3b5caca3b7d23fa90565b6277b0c24dc41775" => :x86_64_linux
  end

  depends_on "cmake" => :build

  uses_from_macos "bison" => :build
  uses_from_macos  "flex" => :build

  def install
    system "cmake", ".", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
    system "make", "install"
    (pkgshare/"tests").install Dir["t/*"]
  end

  test do
    cp_r (pkgshare/"tests").children, testpath
    Dir["*.c"].each do |f|
      system ENV.cc, f, "-o", "test", "-L#{lib}", "-lcue", "-I#{include}"
      system "./test"
      rm "test"
    end
  end
end
