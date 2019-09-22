class Ragout < Formula

  include Language::Python::Virtualenv

  desc "Chromosome-level scaffolding using multiple references"
  homepage "https://github.com/fenderglass/Ragout"
  url "https://github.com/fenderglass/Ragout/archive/2.2.tar.gz"
  sha256 "45d1662863d590415be3cb23f446cb1214f0865b7e0e5559ce2a5e3a456d5049"

  depends_on "python@2"
  depends_on "sibelia"

  resource "decorator" do
    url "https://files.pythonhosted.org/packages/ba/19/1119fe7b1e49b9c8a9f154c930060f37074ea2e8f9f6558efc2eeaa417a2/decorator-4.4.0.tar.gz"
    sha256 "86156361c50488b84a3f148056ea716ca587df2f0de1d34750d35c21312725de"
  end

  resource "networkx" do
    url "https://files.pythonhosted.org/packages/f3/f4/7e20ef40b118478191cec0b58c3192f822cace858c19505c7670961b76b2/networkx-2.2.zip"
    sha256 "45e56f7ab6fe81652fb4bc9f44faddb0e9025f469f602df14e3b2551c2ea5c8b"
  end

  def install
    virtualenv_install_with_resources
  end


end
