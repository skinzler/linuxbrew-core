class Ethereum < Formula
  desc "Official Go implementation of the Ethereum protocol"
  homepage "https://ethereum.github.io/go-ethereum/"
  url "https://github.com/ethereum/go-ethereum/archive/v1.9.10.tar.gz"
  sha256 "d16afd0686a083e2bb3c18862c7d736505355e42edff4c401112dc643c4fad15"
  head "https://github.com/ethereum/go-ethereum.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "9ad8dacb059c73a5637ceccc742ff7de33e7ae07db0c2c52dc1c14de0ea50682" => :catalina
    sha256 "bb1d70b8e481ef48ee297d45f171466c06cd777cf82b914d46b0ca851070f5f9" => :mojave
    sha256 "4bb59f85d1984a8357a3926f02c43bd139d37647b2c2fd4a6a324dbb8b1e0864" => :high_sierra
    sha256 "b0e0f3860be949dbe2af26550e5ba01d4fe4608f3e43b67c59d722ed03273c51" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV.O0 unless OS.mac? # See https://github.com/golang/go/issues/26487
    system "make", "all"
    bin.install Dir["build/bin/*"]
  end

  test do
    (testpath/"genesis.json").write <<~EOS
      {
        "config": {
          "homesteadBlock": 10
        },
        "nonce": "0",
        "difficulty": "0x20000",
        "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
        "coinbase": "0x0000000000000000000000000000000000000000",
        "timestamp": "0x00",
        "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "extraData": "0x",
        "gasLimit": "0x2FEFD8",
        "alloc": {}
      }
    EOS
    system "#{bin}/geth", "--datadir", "testchain", "init", "genesis.json"
    assert_predicate testpath/"testchain/geth/chaindata/000001.log", :exist?,
                     "Failed to create log file"
  end
end
