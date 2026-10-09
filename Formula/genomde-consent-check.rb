class GenomdeConsentCheck < Formula
  include Language::Python::Virtualenv

  desc "Check MII Kerndatensatz Consent (FHIR R4) resources and de-identify them"
  homepage "https://github.com/okohlbacher/genomde-consent-check"
  url "https://github.com/okohlbacher/genomde-consent-check/archive/refs/tags/v2.0.1.tar.gz"
  sha256 "7c9288738e9d0232bd8545ca4b519651010993a412d3a7a5b96c7a3c77da7298"
  license "MIT"

  depends_on "openjdk"
  depends_on "python@3.14"

  def install
    venv = virtualenv_create(libexec, "python3.14")
    venv.pip_install buildpath, build_isolation: true
    # the HL7 validator runs on Homebrew's keg-only openjdk
    %w[genomde-consent-check genomde-consent-deid].each do |cmd|
      (bin/cmd).write_env_script libexec/"bin"/cmd, Language::Java.overridable_java_home_env
    end
  end

  def caveats
    <<~EOS
      The official HL7 FHIR validator (~200 MB) is downloaded separately, once:
        genomde-consent-check --install-validator
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/genomde-consent-check --version")
    assert_match "selftest ok", shell_output("#{bin}/genomde-consent-deid --selftest")
    data = "site-packages/genomde_consent_check/data/mii-consent-2025.0.1"
    examples = libexec.glob("lib/python3*/#{data}/examples").first
    assert_match "2 resources", shell_output("#{bin}/genomde-consent-check --no-hl7 #{examples}")
  end
end
