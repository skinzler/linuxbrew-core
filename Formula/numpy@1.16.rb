class NumpyAT116 < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/d3/4b/f9f4b96c0b1ba43d28a5bdc4b64f0b9d3fbcf31313a51bc766942866a7c7/numpy-1.16.4.zip"
  sha256 "7242be12a58fec245ee9734e625964b97cf7e3f2f7d016603f9e56660ce479c7"
  revision 1

  bottle do
    cellar :any
    sha256 "6c80a9d89e01c944f4142c95f7239d796c9e0a4915c395e99a30d8b221c89280" => :catalina
    sha256 "eae10fb059b9246e2e106572c0534b33fe5848380b945fb2afe90600b0dc5cb1" => :mojave
    sha256 "d7713fb06785ea6dc8ff901858b7c5155f4ca5624d4c5d380b58c1f254ac6268" => :high_sierra
    sha256 "9aec8f47e9c77a03823bdcd15834df53f9d82a32624c2d7b2dce1b833f922af2" => :x86_64_linux
  end

  depends_on :macos # Due to Python 2
  depends_on "gcc" => :build # for gfortran
  depends_on "openblas"
  uses_from_macos "python@2"

  resource "Cython" do
    url "https://files.pythonhosted.org/packages/a5/1f/c7c5450c60a90ce058b47ecf60bb5be2bfe46f952ed1d3b95d1d677588be/Cython-0.29.13.tar.gz"
    sha256 "c29d069a4a30f472482343c866f7486731ad638ef9af92bfe5fca9c7323d638e"
  end

  resource "nose" do
    url "https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  def install
    openblas = Formula["openblas"].opt_prefix
    ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
    ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

    config = <<~EOS
      [openblas]
      libraries = openblas
      library_dirs = #{openblas}/lib
      include_dirs = #{openblas}/include
    EOS

    Pathname("site.cfg").write config

    version = Language::Python.major_minor_version "python"
    dest_path = lib/"python#{version}/site-packages"
    dest_path.mkpath

    nose_path = libexec/"nose/lib/python#{version}/site-packages"
    resource("nose").stage do
      system "python", *Language::Python.setup_install_args(libexec/"nose")
      (dest_path/"homebrew-numpy-nose.pth").write "#{nose_path}\n"
    end

    ENV.prepend_create_path "PYTHONPATH", buildpath/"tools/lib/python#{version}/site-packages"
    resource("Cython").stage do
      system "python", *Language::Python.setup_install_args(buildpath/"tools")
    end

    system "python", "setup.py",
      "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
      "install", "--prefix=#{prefix}",
      "--single-version-externally-managed", "--record=installed.txt"

    rm_f bin/"f2py" # avoid conflict with numpy
  end

  test do
    system "python", "-c", <<~EOS
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end
