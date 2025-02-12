require "language/node"

class NetlifyCli < Formula
  desc "Netlify command-line tool"
  homepage "https://www.netlify.com/docs/cli"
  url "https://registry.npmjs.org/netlify-cli/-/netlify-cli-2.32.0.tgz"
  sha256 "a7164a5e488c874886c8555a912730265f445b9c6994dc0c4b0d9a0c0c8a7431"
  head "https://github.com/netlify/cli.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "5610c95d9e7eb318ee6b8c82a3df2866ad105e9246a8456f9a76aa8ff395a572" => :catalina
    sha256 "e5c454f1acf2ce59d764295f569d1723d53ac69d0e00a4401e43468d11528fa2" => :mojave
    sha256 "e5af5e51b83a67235114e3e9478ba21a6be33e7940a7804894ae870213dad89c" => :high_sierra
    sha256 "97fcddd4a2eff1c06dc3ae0a0f4a3b7d80617f791c3cbf13e288fd6f467bda15" => :x86_64_linux
  end

  depends_on "node"
  depends_on "expect" => :test unless OS.mac?

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.exp").write <<~EOS
      spawn #{bin}/netlify login
      expect "Opening"
    EOS
    assert_match "Logging in", shell_output("expect -f test.exp")
  end
end
