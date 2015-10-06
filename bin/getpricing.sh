#!/bin/bash
. ~/.bashrc
cd "$(dirname "$0")/.." || exit 1
basedir="$(pwd)"

services=(
cloudfront cloudhsm cloudsearch cloudwatch datapipeline dynamodb
ebs ec2 elasticache elasticmapreduce elastictranscoder glacier
importexport rds redshift s3 sns sqs storagegateway swf lambda kinesis
elasticsearch-service efs
)

# 一時ディレクトリを作ってその中で作業する
cd "$(mktemp -d)" || exit 1

# 価格情報が入ったjsを落としてjsonを作る
for s in "${services[@]}"; do
  (
  mkdir -p "$s"
  urls=($(curl -s "https://aws.amazon.com/jp/$s/pricing/" | egrep -io 'model:.*?//[a-z0-9\./_-]+' | perl -pe's|.*//|http://|'))
  for url in "${urls[@]}"; do
    (
    file="$s/$(perl -pe's|.*//||;s|/|__|g' <<< "$url")"
    file_json="$file.json"
    echo "$url"
    curl -s "$url" > "$file" || exit
    (echo 'function callback(j){console.log(JSON.stringify(j,null,2))}'; cat "$file") | node > $file_json
    ) &
  done
  wait
  ) &
done
wait

# 一時ディレクトリの中身で data を更新
rsync -av ./ "$basedir/data/" --exclude=\*.js --delete
