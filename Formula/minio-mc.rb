class MinioMc < Formula
  desc "Replacement for ls, cp and other commands for object storage"
  homepage "https://github.com/minio/mc"
  url "https://github.com/minio/mc.git",
      :tag      => "RELEASE.2020-02-14T19-35-50Z",
      :revision => "2f2aecb09dd15cc65ca828dc7946d4de98dbc7df"
  version "20200214193550"

  bottle do
    cellar :any_skip_relocation
    sha256 "09555a28744b1dbdad119a7a89f01136b12c36609c665154d0709018c5347b3e" => :catalina
    sha256 "241b4f5587aa33ba5fe1fa7d96fb80b446b40b89bbeefc801306274573c32371" => :mojave
    sha256 "ac3741331f18f549f0836984f3617224ea62c93ec81ae81d6a6e4cb8689629bb" => :high_sierra
    sha256 "737f57868abab4c2b78fdea54df597a113a8026c594a18367f18522506316475" => :x86_64_linux
  end

  depends_on "go" => :build

  conflicts_with "midnight-commander", :because => "Both install a `mc` binary"

  def install
    if build.head?
      system "go", "build", "-trimpath", "-o", bin/"mc"
    else
      minio_release = `git tag --points-at HEAD`.chomp
      minio_version = minio_release.gsub(/RELEASE\./, "").chomp.gsub(/T(\d+)\-(\d+)\-(\d+)Z/, 'T\1:\2:\3Z')
      minio_commit = `git rev-parse HEAD`.chomp
      proj = "github.com/minio/mc"

      system "go", "build", "-trimpath", "-o", bin/"mc", "-ldflags", <<~EOS
        -X #{proj}/cmd.Version=#{minio_version}
        -X #{proj}/cmd.ReleaseTag=#{minio_release}
        -X #{proj}/cmd.CommitID=#{minio_commit}
      EOS
    end

    prefix.install_metafiles
  end

  test do
    system bin/"mc", "mb", testpath/"test"
    assert_predicate testpath/"test", :exist?
  end
end
