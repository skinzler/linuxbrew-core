class Fdupes < Formula
  desc "Identify or delete duplicate files"
  homepage "https://github.com/adrianlopezroche/fdupes"
  url "https://github.com/adrianlopezroche/fdupes/archive/v1.6.1.tar.gz"
  sha256 "9d6b6fdb0b8419815b4df3bdfd0aebc135b8276c90bbbe78ebe6af0b88ba49ea"
  version_scheme 1

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "461c8de0f269c38289159a5b41935a788955bff38fdc7c104108c9e3dfac22ea" => :catalina
    sha256 "69dcc3c64c3debb7f3b927e16fc6e7e2250c4c35db280a8fd97315fcc48628a4" => :mojave
    sha256 "2ca42f56f5b4e48a4a51cf9687108eb2ebbbf43ce610596d4420be1a68f1ec1b" => :high_sierra
    sha256 "4838e3104ea06e61d7acce5f482ff80bae1d634f29a1edd44e388b9f8c63f19b" => :sierra
    sha256 "b0b7afcd64459cfc3c2bb95ac92e1aa7f6531fbf05603e472c97c5d4e72c94b7" => :el_capitan
    sha256 "ce706b289e019a30c4d07a307ae2c5c10ef1b886e4ee8e5e62f7275a9213a370" => :yosemite
    sha256 "a5e2a52f2502942856899ae9332e0f279b83fb27fcfc9fee00ace198d95fc202" => :x86_64_linux
  end

  def install
    inreplace "Makefile", "gcc", "#{ENV.cc} #{ENV.cflags}"
    system "make", "fdupes"
    bin.install "fdupes"
    man1.install "fdupes.1"
  end

  test do
    touch "a"
    touch "b"

    dupes = shell_output("#{bin}/fdupes .").strip.split("\n").sort
    assert_equal ["./a", "./b"], dupes
  end
end
