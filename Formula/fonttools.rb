class Fonttools < Formula
  include Language::Python::Virtualenv

  desc "Library for manipulating fonts"
  homepage "https://github.com/fonttools/fonttools"
  url "https://github.com/fonttools/fonttools/releases/download/4.3.0/fonttools-4.3.0.zip"
  sha256 "0c16d5da7846a92aedcb448277d13d3b729f7de48a917768d97ebd0d17067d7f"
  head "https://github.com/fonttools/fonttools.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "17c1ba66fb5d9ad6a57f914b09c7e7a3c58f90e2f13dcb4367b19f3872897b18" => :catalina
    sha256 "529885e154a585b98d768b5f987cb7030ac1309aaddb8ab99d48206ea20200e4" => :mojave
    sha256 "8f44c27fc8075fa8e9b5fbf7e61d6a6c36b203f4ae9060b2b2ff365ad57a25b7" => :high_sierra
    sha256 "921578d4c07776ca4cbe4e87be301e725c4624a913a192bcb8e59e9b1c6e19b6" => :x86_64_linux
  end

  depends_on "python@3.8"

  def install
    virtualenv_install_with_resources
  end

  test do
    unless OS.mac?
      assert_match "usage", shell_output("#{bin}/ttx -h")
      return
    end
    cp "/System/Library/Fonts/ZapfDingbats.ttf", testpath
    system bin/"ttx", "ZapfDingbats.ttf"
  end
end
