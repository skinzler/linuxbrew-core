class GitArchiveAll < Formula
  desc "Archive a project and its submodules"
  homepage "https://github.com/Kentzo/git-archive-all"
  url "https://github.com/Kentzo/git-archive-all/archive/1.20.0.tar.gz"
  sha256 "816cbd5fee43779be3e3527ddad011154bfdc496f93615c0d63340157adf5665"
  revision 1 unless OS.mac?
  head "https://github.com/Kentzo/git-archive-all.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "f19b26ad5f84a0049ff16c4b0a2e5080eb06ba3d5925c4622b09b2dec80d3be9" => :catalina
    sha256 "f19b26ad5f84a0049ff16c4b0a2e5080eb06ba3d5925c4622b09b2dec80d3be9" => :mojave
    sha256 "f19b26ad5f84a0049ff16c4b0a2e5080eb06ba3d5925c4622b09b2dec80d3be9" => :high_sierra
    sha256 "527ea5590831e9b16c17223e0a6613568db2eabea798fbafed375cea6cbcc8bf" => :x86_64_linux
  end

  depends_on "python@3.8" unless OS.mac?

  def install
    unless OS.mac?
      Dir["*.py"].each do |file|
        next unless File.read(file).include?("/usr/bin/env python")

        inreplace file, %r{#! ?/usr/bin/env python}, "#!#{Formula["python@3.8"].opt_bin/"python3"}"
      end
    end

    system "make", "prefix=#{prefix}", "install"
  end

  test do
    (testpath/".gitconfig").write <<~EOS
      [user]
        name = Real Person
        email = notacat@hotmail.cat
    EOS
    system "git", "init"
    touch "homebrew"
    system "git", "add", "homebrew"
    system "git", "commit", "--message", "brewing"

    assert_equal "#{testpath.realpath}/homebrew => archive/homebrew",
                 shell_output("#{bin}/git-archive-all --dry-run ./archive").chomp
  end
end
