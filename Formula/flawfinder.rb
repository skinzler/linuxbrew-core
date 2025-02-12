class Flawfinder < Formula
  desc "Examines code and reports possible security weaknesses"
  homepage "https://www.dwheeler.com/flawfinder/"
  url "https://www.dwheeler.com/flawfinder/flawfinder-2.0.10.tar.gz"
  sha256 "f1dcb1ec3e35685e46a8512137b8062daa1d0327900177998a405feab608adeb"
  head "https://git.code.sf.net/p/flawfinder/code.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "8af2dc44618f0068854fc86e2b6fd100faf09ed25b44cf9de5d44d6fe5999927" => :catalina
    sha256 "f782448190a609f5b8e928428b7a5dece33a9ed8eea00707e8e2ec5d69f3aed2" => :mojave
    sha256 "f782448190a609f5b8e928428b7a5dece33a9ed8eea00707e8e2ec5d69f3aed2" => :high_sierra
    sha256 "5d58c32a6c4c947552e23265e71f8138daf6663cf2de5b6f50fd00f10ae8e2fb" => :sierra
    sha256 "a7f42fb52b0228d5bff2021f9efd3187b4ea48e499694d9492a30ae47120e673" => :x86_64_linux
  end

  depends_on :macos # Due to Python 2
  uses_from_macos "python@2"

  resource "flaws" do
    url "https://www.dwheeler.com/flawfinder/test.c"
    sha256 "4a9687a091b87eed864d3e35a864146a85a3467eb2ae0800a72e330496f0aec3"
  end

  def install
    system "make", "prefix=#{prefix}", "install"
  end

  test do
    resource("flaws").stage do
      assert_match "Hits = 36",
                   shell_output("#{bin}/flawfinder test.c")
    end
  end
end
