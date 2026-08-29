class Smry < Formula
  desc "Read public articles, PDFs, and videos as clean source-grounded text"
  homepage "https://r.smry.ai"
  url "https://github.com/mrmps/homebrew-smry/releases/download/v0.1.0/smry"
  version "0.1.0"
  sha256 "8ae15330e82ca2cca1a9d70eed3f5db468e13f80f685c938ad837e82755c6db2"
  license "MIT"

  def install
    bin.install cached_download => "smry"
  end

  test do
    assert_match "smry 0.1.0", shell_output("#{bin}/smry --version")
  end
end
