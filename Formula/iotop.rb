class Iotop < Formula
  desc "Top-like UI used to show which process is using the I/O"
  homepage "http://guichaz.free.fr/iotop/"
  url "http://guichaz.free.fr/iotop/files/iotop-0.6.tar.bz2"
  sha256 "3adea2a24eda49bbbaeb4e6ed2042355b441dbd7161e883067a02bfc8dcef75b"
  revision 1
  head "git://repo.or.cz/iotop.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "e04a07adf72ff53c32d91f9c982b615be8866181d018c03bddf9c47a8c00be53" => :x86_64_linux
  end

  depends_on :linux
  depends_on :macos # Due to Python 2
  depends_on "python@2"

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    assert_match "DISK READ and DISK WRITE", shell_output("#{bin}/iotop --help")
  end
end
