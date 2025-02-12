class Libzip < Formula
  desc "C library for reading, creating, and modifying zip archives"
  homepage "https://libzip.org/"
  url "https://libzip.org/download/libzip-1.6.1.tar.xz"
  sha256 "705dac7a671b3f440181481e607b0908129a9cf1ddfcba75d66436c0e7d33641"

  bottle do
    cellar :any_skip_relocation
    sha256 "d0d5f0722e0914fb33a8e1bc72b879577876a4b8ad554b93b50efc0e2436a591" => :catalina
    sha256 "d3e6626651e816fc0f14800669cdd145f7e4a8e6f75f9a689b65d48a68ce4687" => :mojave
    sha256 "2d973dfbb440bf9569f1b5f9c81d6de52c8a41ba2da64c5cfb1b1d5a408235c8" => :high_sierra
    sha256 "da1a6abed8d23dc70ccc3a88839da39033f0318fa24a6a73b6a6e156edc5882c" => :x86_64_linux
  end

  depends_on "cmake" => :build

  conflicts_with "libtcod", "minizip2",
    :because => "libtcod, libzip and minizip2 install a `zip.h` header"

  unless OS.mac?
    depends_on "openssl@1.1"
    depends_on "xz" # For LZMA
  end

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    zip = OS.mac? ? "/usr/bin/zip" : which("zip")
    if zip.nil?
      opoo "Not testing unzip, because it requires zip, which is unavailable."
      return
    end

    touch "file1"
    system "zip", "file1.zip", "file1"
    touch "file2"
    system "zip", "file2.zip", "file1", "file2"
    assert_match /\+.*file2/, shell_output("#{bin}/zipcmp -v file1.zip file2.zip", 1)
  end
end
