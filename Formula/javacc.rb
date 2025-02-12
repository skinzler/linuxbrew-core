class Javacc < Formula
  desc "Parser generator for use with Java applications"
  homepage "https://javacc.org/"
  url "https://github.com/javacc/javacc/archive/7.0.5.tar.gz"
  sha256 "d1502f8a7ed607de17427a1f33e490a33b0c2d5612879e812126bf95e7ed11f4"

  bottle do
    cellar :any_skip_relocation
    sha256 "9c275d1d13bdf1ca8a1055b7eebd36b965900df3e437212f088b81c1cbc1cd45" => :catalina
    sha256 "9ff7ba84bb480e5cd6e7e345a862c53388a3c6ae9ebd9a2fcdae39acb19522d4" => :mojave
    sha256 "d0f91587db34aeb3f695cc36ced30032515dc33e88fd41dc7623e4ad396c74d7" => :high_sierra
    sha256 "01350f87eb59e0daf903e4c887e0ddf2141c77f4bccdd4d23c01ef8fde779750" => :x86_64_linux
  end

  depends_on "ant" => :build
  depends_on :java

  def install
    system "ant"
    (libexec/"lib").install "target/javacc-#{version}.jar"
    doc.install Dir["docs/*"]
    (share/"examples").install Dir["examples/*"]
    %w[javacc jjdoc jjtree].each do |script|
      (bin/script).write <<~SH
        #!/bin/bash
        exec java -classpath #{libexec/"lib/javacc-#{version}.jar"} #{script} "$@"
      SH
    end
  end

  test do
    src_file = share/"examples/SimpleExamples/Simple1.jj"

    output_file_stem = testpath/"Simple1"

    system bin/"javacc", src_file
    assert_predicate output_file_stem.sub_ext(".java"), :exist?

    system bin/"jjtree", src_file
    assert_predicate output_file_stem.sub_ext(".jj.jj"), :exist?

    system bin/"jjdoc", src_file
    assert_predicate output_file_stem.sub_ext(".html"), :exist?
  end
end
