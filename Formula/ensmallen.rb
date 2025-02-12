class Ensmallen < Formula
  desc "Flexible C++ library for efficient mathematical optimization"
  homepage "https://ensmallen.org"
  url "https://github.com/mlpack/ensmallen/archive/2.11.2.tar.gz"
  sha256 "314045d7d63997deb0ea36d0046506569aff58fa7dbd54ffaff5f9ba78ff5ff8"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "378eb54b3038b432e1a179c154f86beb43df1301a382eaed8ccab2afdecb7251" => :catalina
    sha256 "378eb54b3038b432e1a179c154f86beb43df1301a382eaed8ccab2afdecb7251" => :mojave
    sha256 "378eb54b3038b432e1a179c154f86beb43df1301a382eaed8ccab2afdecb7251" => :high_sierra
    sha256 "65b02961b6155e3834d0daa1bafd0c1930fb61979b3e5100a6c743794ddf1037" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "armadillo"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <ensmallen.hpp>
      using namespace ens;
      int main()
      {
        test::RosenbrockFunction f;
        arma::mat coordinates = f.GetInitialPoint();
        Adam optimizer(0.001, 32, 0.9, 0.999, 1e-8, 3, 1e-5, true);
        optimizer.Optimize(f, coordinates);
        return 0;
      }
    EOS
    cxx_with_flags = ENV.cxx.split + ["test.cpp",
                                      "-std=c++11",
                                      "-I#{include}",
                                      "-I#{Formula["armadillo"].opt_lib}/libarmadillo",
                                      "-o", "test"]
    system *cxx_with_flags
  end
end
