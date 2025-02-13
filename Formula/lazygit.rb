class Lazygit < Formula
  desc "Simple terminal UI for git commands"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/jesseduffield/lazygit/archive/v0.14.3.tar.gz"
  sha256 "9ff8672aff431f5ccd943cc2a87877950b1efd7e9987a3c024c9b626a2a7ee81"

  bottle do
    cellar :any_skip_relocation
    sha256 "651ed21b9ce26b00569fceb2ad14a105bbfb62d94e38dcf243be0d10a75bc53e" => :catalina
    sha256 "7a21f6b9737281e8d5cefbae9903109fda066eac32ae4d4e2cd26e38f1e27e09" => :mojave
    sha256 "f7b7e619984972519bbc6f227066bb734943dff49e51e32c0860e71114cbd300" => :high_sierra
    sha256 "8e909fc9ef031a80047c39466498be355e6f4df8722c54a3e638d08e8e499dfa" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-mod=vendor", "-o", bin/"lazygit",
      "-ldflags", "-X main.version=#{version} -X main.buildSource=homebrew"
  end

  # lazygit is a terminal GUI, but it can be run in 'client mode' for example to write to git's todo file
  test do
    (testpath/"git-rebase-todo").write ""
    ENV["LAZYGIT_CLIENT_COMMAND"] = "INTERACTIVE_REBASE"
    ENV["LAZYGIT_REBASE_TODO"] = "foo"
    system "#{bin}/lazygit", "git-rebase-todo"
    assert_match "foo", (testpath/"git-rebase-todo").read
  end
end
