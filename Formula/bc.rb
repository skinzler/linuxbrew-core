class Bc < Formula
  desc "Arbitrary precision numeric processing language"
  homepage "https://www.gnu.org/software/bc/"
  url "https://ftp.gnu.org/gnu/bc/bc-1.07.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/bc/bc-1.07.1.tar.gz"
  sha256 "62adfca89b0a1c0164c2cdca59ca210c1d44c3ffc46daf9931cf4942664cb02a"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "9fdbf6f45737082f911073b3c291399487bc3a3cfd1285e0da389436064c438f" => :catalina
    sha256 "78372f9830096b6d63fa7278e141924869a9aaee250b2ac1135594e67ba76c09" => :mojave
    sha256 "0baf2e31191d80258636186bf9adcdf6b3f554f213d36cb3054213f736e52bf1" => :high_sierra
    sha256 "1d8f0459c0b67aae275c43e01e5312146be72163acadd3d6c8f2bc440181508c" => :sierra
    sha256 "e5c4b3fa712d705c3cc9bfae12242c9b4dc429e329c61d12aa01b65c1623a11f" => :el_capitan
    sha256 "57de5ac07f99f1b7b67b854997e9f2a6fb69664f904ea3c3cf4538d509227d91" => :x86_64_linux
  end

  keg_only :provided_by_macos

  unless OS.mac?
    depends_on "ed" => :build
    depends_on "texinfo" => :build
  end

  uses_from_macos "bison" => :build
  uses_from_macos "flex"

  def install
    # prevent user BC_ENV_ARGS from interfering with or influencing the
    # bootstrap phase of the build, particularly
    # BC_ENV_ARGS="--mathlib=./my_custom_stuff.b"
    ENV.delete("BC_ENV_ARGS")
    system "./configure",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}",
      "--infodir=#{info}",
      "--mandir=#{man}",
      "--with-libedit"
    system "make", "install"
  end

  test do
    system "#{bin}/bc", "--version"
    assert_match "2", pipe_output("#{bin}/bc", "1+1\n")
  end
end
