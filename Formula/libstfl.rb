class Libstfl < Formula
  desc "Library implementing a curses-based widget set for terminals"
  homepage "http://www.clifford.at/stfl/"
  url "http://www.clifford.at/stfl/stfl-0.24.tar.gz"
  sha256 "d4a7aa181a475aaf8a8914a8ccb2a7ff28919d4c8c0f8a061e17a0c36869c090"
  revision 9

  bottle do
    cellar :any
    sha256 "540ff6bbdcbe0ff3fe2a2cb6e485819374ce5938e9cee284d6087431be3c8b1e" => :catalina
    sha256 "3d70772668a1b05b187c2db04a6ab499919eff506a8f48d2248c36126d840442" => :mojave
    sha256 "533ea07754699c5ca284752d18378ff482f06eee9257c59e5fd49f445c6ff4b9" => :high_sierra
  end

  depends_on :macos # Due to Python 2
  depends_on "swig" => :build
  depends_on "ruby"

  uses_from_macos "perl"
  uses_from_macos "python@2"

  def install
    if OS.mac?
      ENV.append "LDLIBS", "-liconv"
      ENV.append "LIBS", "-lncurses -liconv -lruby"
    else
      ENV.append "LIBS", "-lncurses -lruby"
    end

    %w[
      stfl.pc.in
      perl5/Makefile.PL
      ruby/Makefile.snippet
    ].each do |f|
      inreplace f, "ncursesw", "ncurses"
    end

    inreplace "stfl_internals.h", "ncursesw/ncurses.h", "ncurses.h"

    inreplace "Makefile" do |s|
      s.gsub! "ncursesw", "ncurses"
      s.gsub! "-Wl,-soname,$(SONAME)", "-Wl"
      s.gsub! "libstfl.so.$(VERSION)", "libstfl.$(VERSION).dylib"
      s.gsub! "libstfl.so", "libstfl.dylib"
    end

    inreplace "python/Makefile.snippet" do |s|
      # Install into the site-packages in the Cellar (so uninstall works)
      s.change_make_var! "PYTHON_SITEARCH", lib/"python2.7/site-packages"
      s.gsub! "lib-dynload/", ""
      s.gsub! "ncursesw", "ncurses"
      if OS.mac?
        s.gsub! "gcc", "gcc -undefined dynamic_lookup #{`python-config --cflags`.chomp}"
        s.gsub! "-lncurses", "-lncurses -liconv"
      else
        s.gsub! "gcc", "gcc #{`python-config --cflags`.chomp}"
      end
    end

    # Fails race condition of test:
    #   ImportError: dynamic module does not define init function (init_stfl)
    #   make: *** [python/_stfl.so] Error 1
    ENV.deparallelize

    system "make"

    inreplace "perl5/Makefile", "Network/Library", libexec/"lib/perl5" if OS.mac?
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <stfl.h>
      int main() {
        stfl_ipool * pool = stfl_ipool_create("utf-8");
        stfl_ipool_destroy(pool);
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}", "-lstfl", "-o", "test"
    system "./test"
  end
end
