# typed: false
# frozen_string_literal: true

# This file was generated by GoReleaser. DO NOT EDIT.
require_relative "lib/custom_download_strategy"
class Scaleops < Formula
  desc "ScaleOps CLI."
  homepage "https://scaleops.sh/"
  version "0.0.3"
  license "Private"

  on_macos do
    url "https://github.com/scaleops-sh/scaleops-sh/releases/download/v0.0.3/scaleops_0.0.3_darwin_all.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "dc39d322aa1e1c7b2656f724207763dadfa46de5d5c6ba1e470b766325363a16"

    def install
      bin.install "scaleops"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/scaleops-sh/scaleops-sh/releases/download/v0.0.3/scaleops_0.0.3_linux_arm64.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "b9148cc5c0c852a69ca3d7f4933351984256b60081273e2b4b56d18041f68c0d"

      def install
        bin.install "scaleops"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/scaleops-sh/scaleops-sh/releases/download/v0.0.3/scaleops_0.0.3_linux_amd64.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "fc1e362fb1bf3ac59340aac1e9b24795d021220b431b7b6bddc41dc45c59219a"

      def install
        bin.install "scaleops"
      end
    end
  end

  depends_on "helm"

  def caveats; <<~EOS
    How to use this binary
  EOS
  end
end
