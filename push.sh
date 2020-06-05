##拉取代码

sleep 1

git add .
echo "请输入本次备注信息:"
read message
git commit -m "$message" --no-verify
echo '开始拉取代码...'
git pull origin master

pid=$!

wait ${pid}

## 提交代码

sleep 1

echo '开始提交代码...'
git push origin master

pid=$!

wait ${pid}

echo 'end...'
sleep 1