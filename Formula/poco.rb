class Poco < Formula
  desc "C++ class libraries for building network and internet-based applications"
  homepage "https://pocoproject.org/"
  url "https://pocoproject.org/releases/poco-1.10.0/poco-1.10.0-all.tar.gz"
  sha256 "fa8bbe29da53882b053e37f94e19f2de4be85631b3186fff3bed8027427b7777"
  head "https://github.com/pocoproject/poco.git", :branch => "develop"

  bottle do
    cellar :any
    sha256 "67ee47718a0d6aa3cd20cdc676925c2b9e15e3776d049c6fa1e04002cc475884" => :catalina
    sha256 "53bb526ee1c9b8b5dd58b22c53aa06b7d59dabafdadddc83d10abbd5db04d364" => :mojave
    sha256 "dec904f7fb887043b0ddea47622a359278e08988c6b5121e3c4fd09e76703274" => :high_sierra
    sha256 "0e4e7e4cadfb66e81bf0eb79d14ee30b4c94bae4ad909329c03c532dc3e0e4bb" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args,
                            "-DENABLE_DATA_MYSQL=OFF",
                            "-DENABLE_DATA_ODBC=OFF"
      system "make", "install"
    end
  end

  test do
    system bin/"cpspc", "-h"
  end
end
