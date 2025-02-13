class X264 < Formula
  desc "H.264/AVC encoder"
  homepage "https://www.videolan.org/developers/x264.html"
  revision 1
  head "https://git.videolan.org/git/x264.git"

  stable do
    # the latest commit on the stable branch
    url "https://git.videolan.org/git/x264.git",
        :revision => "0a84d986e7020f8344f00752e3600b9769cc1e85"
    version "r2917"
  end

  bottle do
    cellar :any
    rebuild 1
    sha256 "9e49fa8cc8e0bd02bdb85f8b2def682a8c6aab5d3f7bfe6bb51e2e78da1b2eb9" => :catalina
    sha256 "07d6a4de866c38296a3cb788c3370857bd745e88cd7e1723fc0261c4e44a1081" => :mojave
    sha256 "80b6d49faed147546c8639bdc09143968587d7fed7c45dcd9c4e0f56cdb932ff" => :high_sierra
    sha256 "749ed57861f80c753f35380898e4d82a67de5471254a0a18a30752d22a1d9917" => :x86_64_linux
  end

  depends_on "nasm" => :build

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-lsmash
      --disable-swscale
      --disable-ffms
      --enable-shared
      --enable-static
      --enable-strip
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdint.h>
      #include <x264.h>

      int main()
      {
          x264_picture_t pic;
          x264_picture_init(&pic);
          x264_picture_alloc(&pic, 1, 1, 1);
          x264_picture_clean(&pic);
          return 0;
      }
    EOS
    system ENV.cc, "-L{lib}", "test.c", "-lx264", "-o", "test"
    system "./test"
  end
end
