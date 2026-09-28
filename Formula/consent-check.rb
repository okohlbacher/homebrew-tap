class ConsentCheck < Formula
  include Language::Python::Virtualenv

  desc "Check MII Kerndatensatz Consent (FHIR R4) resources and de-identify them"
  homepage "https://github.com/okohlbacher/consent-check"
  url "https://github.com/okohlbacher/consent-check/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "bc63a9549c25e5043b49b032b60d6ac6e3a24c5ccada09eab31872b4d9ab620a"
  license "MIT"

  depends_on "openjdk"
  depends_on "python@3.14"

  def install
    venv = virtualenv_create(libexec, "python3.14")
    venv.pip_install buildpath, build_isolation: true
    # the HL7 validator runs on Homebrew's keg-only openjdk
    %w[consent-check consent-deid].each do |cmd|
      (bin/cmd).write_env_script libexec/"bin"/cmd, Language::Java.overridable_java_home_env
    end
  end

  def caveats
    <<~EOS
      The official HL7 FHIR validator (~200 MB) is downloaded separately, once:
        consent-check --install-validator
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/consent-check --version")
    assert_match "selftest ok", shell_output("#{bin}/consent-deid --selftest")
    examples = libexec.glob("lib/python3*/site-packages/consent_check/data/mii-consent-2025.0.1/examples").first
    assert_match "2 resources", shell_output("#{bin}/consent-check --no-hl7 #{examples}")
  end
end
