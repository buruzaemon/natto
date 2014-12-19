# -*- coding: utf-8 -*-
$: << "lib" 
require "benchmark"

require "natto"
require "MeCab"

@mecab_tagger = MeCab::Tagger.new
@natto_mecab = Natto::MeCab.new

def run(n)
  GC.disable
  n.times do
    yield
  end
  GC.enable
end

def benchmark(text)
#  n = 10
  n = 10000
  puts("text: #{text}")
  Benchmark.bmbm(10) do |job|
    job.report("MeCab") do
      run(n) do
        @mecab_tagger.parse(text)
      end
    end

    job.report("natto") do
      run(n) do
        @natto_mecab.parse(text)
      end
    end
  end
  puts
end

#benchmark("私の名前は中野です。")
#benchmark("すもももももももものうち")
#benchmark("MeCabは 京都大学情報学研究科−日本電信電話株式会社コミュニケーション科学基礎研究所 共同研究ユニットプロジェクトを通じて開発されたオープンソース 形態素解析エンジンです. 言語, 辞書,コーパスに依存しない汎用的な設計を 基本方針としています. パラメータの推定に Conditional Random Fields (CRF) を用 いており, ChaSenが採用している 隠れマルコフモデルに比べ性能が向上しています。また、平均的に ChaSen, Juman, KAKASIより高速に動作します. ちなみに和布蕪(めかぶ)は, 作者の好物です.")
benchmark("太郎はこの本を二郎を見た女性に渡した。")
