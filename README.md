# Ruby & Linux Practice

Raspberry Pi 4 で、Linux と Ruby の基礎・運用を学習中。

## 学習内容

- Linux基本操作
- VS Code Remote SSH
- Ruby基礎
- CPU温度取得
- 条件分岐による状態判定
- ログ保存・集計
- GitHubによる履歴管理

## 実装例

RubyからLinuxコマンドを実行し、Raspberry PiのCPU温度を取得。
取得した温度を以下の3段階で判定します。

- NORMAL
- WARM
- WARNING

また、測定結果をログへ保存し、測定回数・最高温度・平均温度を集計します。