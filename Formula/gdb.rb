class Gdb < Formula
  desc "GNU debugger"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-9.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-9.1.tar.xz"
  sha256 "699e0ec832fdd2f21c8266171ea5bf44024bd05164fdf064e4d10cc4cf0d1737"
  head "https://sourceware.org/git/binutils-gdb.git"

  bottle do
    sha256 "efa76a0bc52bef935730afb32ab848446d92d7f8c38f2ef694fdcf3d20b67a44" => :catalina
    sha256 "e3159449ff06712174dae7c3f513196eb02439e83057e2779531ec94b422c278" => :mojave
    sha256 "4cde626aa5d32dde54d70bd531a06e65051e7ac7371f1970b6b9c838f565239c" => :high_sierra
    sha256 "fb9bc825e98c8aa63215706ff9dcec2af897bc8b5ce4c5dfac427ede1d4314ba" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  unless OS.mac?
    depends_on "texinfo" => :build
    depends_on "python"
    depends_on "xz"
  end

  uses_from_macos "expat"
  uses_from_macos "ncurses"

  conflicts_with "i386-elf-gdb", :because => "both install include/gdb, share/gdb and share/info"

  fails_with :clang do
    build 800
    cause <<~EOS
      probe.c:63:28: error: default initialization of an object of const type
      'const any_static_probe_ops' without a user-provided default constructor
    EOS
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --enable-targets=all
      --disable-binutils
    ]
    if OS.mac?
      arg << "--with-python=/usr"
    else
      args << "--with-python=#{Formula["python"].opt_bin}/python3"
      ENV.append "CPPFLAGS", "-I#{Formula["python"].opt_libexec}"
    end

    mkdir "build" do
      system "../configure", *args
      system "make"

      # Don't install bfd or opcodes, as they are provided by binutils
      system "make", "install-gdb"
    end
  end

  def caveats; <<~EOS
    gdb requires special privileges to access Mach ports.
    You will need to codesign the binary. For instructions, see:

      https://sourceware.org/gdb/wiki/BuildingOnDarwin

    On 10.12 (Sierra) or later with SIP, you need to run this:

      echo "set startup-with-shell off" >> ~/.gdbinit
  EOS
  end

  test do
    system bin/"gdb", bin/"gdb", "-configuration"
  end
end
