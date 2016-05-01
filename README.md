# 遺伝的アルゴリズム
遺伝的アルゴリズムとは，生物が環境に適応して進化していく過程を工学的に模倣した学習的アルゴリズムである。
データ（解の候補）を遺伝子で表現した「個体」を複数用意し、適応度の高い個体を優先的に選択して交叉（組み換え）・突然変異などの操作を繰り返しながら解を探索する。

## 母集団
POPULATION_MEMBER_COUNTを母集団の数とする。

## 評価
使用可能文字を一列に並べ、位置の差が小さいものを優秀な遺伝子と評価する。

## 選択
ランキング方式で、劣等な2遺伝子を除外する。
不足になった2遺伝子は、交叉によって作られた2つを次世代に追加する。

## 交叉
対象の遺伝子から、新しい遺伝子を作成する。一点交叉を採用。

## 突然変異
MUTATION_RATEの確率でMUTATION_COUNT個の遺伝子が使用可能文字内の前後に入れ替わる。

## 終了判定
探索対象と同一な遺伝子の出現を以って探索を終了する。