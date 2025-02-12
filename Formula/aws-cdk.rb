require "language/node"

class AwsCdk < Formula
  desc "AWS Cloud Development Kit - framework for defining AWS infra as code"
  homepage "https://github.com/aws/aws-cdk"
  url "https://registry.npmjs.org/aws-cdk/-/aws-cdk-1.23.0.tgz"
  sha256 "c0159aaedc7f773395390dae47007d7e784d5b491ae400168678e62906a82487"

  bottle do
    cellar :any_skip_relocation
    sha256 "653ef5d317183ab544f55b4b3369424828b8c95f8ef9a3c00cf6afd29b446642" => :catalina
    sha256 "59bd77156102034d159e84c1742e1f9e098063168a4886fa208ea5693b19da3e" => :mojave
    sha256 "ec4bfc5c04ac59efe44314ab44046259dfeb32083b5a54894d275e78fda6ed91" => :high_sierra
    sha256 "e0091ad78ef59c0a05bd86dc458e76e9301e23ee40c9bb660c60da98757c689d" => :x86_64_linux
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    mkdir "testapp"
    cd testpath/"testapp"
    shell_output("#{bin}/cdk init app --language=javascript")
    list = shell_output("#{bin}/cdk list")
    cdkversion = shell_output("#{bin}/cdk --version")
    assert_match "TestappStack", list
    assert_match version.to_s, cdkversion
  end
end
