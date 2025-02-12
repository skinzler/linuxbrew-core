class Memcached < Formula
  desc "High performance, distributed memory object caching system"
  homepage "https://memcached.org/"
  url "https://www.memcached.org/files/memcached-1.5.22.tar.gz"
  sha256 "c2b47e9d20575a2367087c229636ffc3fb699a6c3a7f3a22f44402f25f5f1f93"
  head "https://github.com/memcached/memcached.git"

  bottle do
    cellar :any
    sha256 "c06d96884f09dc8ff4c1d6bed20366db116b4c3b837c7bd5d294d831848af454" => :catalina
    sha256 "f041a91c262c14161be71a27e47b7b37d837e27fbb2f16ad38036ff3481fd14c" => :mojave
    sha256 "2fee77cf1c8777a1c6c1eb64086bca30a6ae684b7ec4bfbb41f107c24de8b2c8" => :high_sierra
    sha256 "d9ca6376b59531b72bffd6597b6a7d3b6a74e86adc2b27c37d02004e9560e2e9" => :x86_64_linux
  end

  depends_on "libevent"

  # fix for https://github.com/memcached/memcached/issues/598, included in next version
  patch do
    url "https://github.com/memcached/memcached/commit/7e3a2991.diff?full_index=1"
    sha256 "063a2d91f863c4c6139ff5f0355bd880aca89b6da813515e0f0d11d9295189b4"
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-coverage", "--enable-tls"
    system "make", "install"
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/memcached/bin/memcached"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>KeepAlive</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/memcached</string>
        <string>-l</string>
        <string>localhost</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
  EOS
  end

  test do
    pidfile = testpath/"memcached.pid"
    # Assumes port 11211 is not already taken
    if !OS.mac? && ENV["CI"]
      system bin/"memcached", "-u", ENV["USER"], "--listen=127.0.0.1:11211", "--daemon", "--pidfile=#{pidfile}"
    else
      system bin/"memcached", "--listen=localhost:11211", "--daemon", "--pidfile=#{pidfile}"
    end
    sleep 1
    assert_predicate pidfile, :exist?, "Failed to start memcached daemon"
    pid = (testpath/"memcached.pid").read.chomp.to_i
    Process.kill "TERM", pid
  end
end
