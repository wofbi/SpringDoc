echo "切换到主分支"
git checkout main

echo "添加所有文件"
git add .

echo "提交更改，注释为“部署”"
git commit -m "部署"

echo "从远程仓库中拉取最新版本的主分支"
git pull origin main

if [ $? -eq 0 ]; then
echo "main 分支 git pull 执行成功"
else
echo "main 分支 git pull 执行失败"
exit 1
fi

echo "将本地更改推送到远程仓库"
git push

echo "如果 page_tmp 分支存在则删除本地名为 page_tmp 的分支"

branch_exists=$(git branch --list page_tmp)
if [[ -n $branch_exists ]]; then
    git branch -D page_tmp
fi

echo "创建新分支 page_tmp，将其基于主分支"
git branch page_tmp main

echo "切换到 page_tmp 分支"
git checkout page_tmp

echo "在当前目录中安装 npm 包"
npm install --verbose

echo "运行 npm 脚本 build"
npm run build

if [ $? -eq 0 ]; then
    echo "npm run build 执行成功"
else
    echo "npm run build 执行失败"
    exit 1
fi

echo "将 docs/.vitepress/dist 目录下的所有文件复制到当前目录"
cp -R docs/.vitepress/dist/* .

echo "将新文件添加到暂存区"
git add .

echo "提交更改，注释为“部署”"
git commit -m "部署"

echo "切换到 page 分支"
git checkout page

echo "从远程仓库中拉取最新版本的 page 分支"
git pull

if [ $? -eq 0 ]; then
    echo "page 分支 git pull 执行成功"
else
    echo "page 分支 git pull 执行失败"
    exit 1
fi

echo "将 page_tmp 分支合并到 page 分支，使用 theirs 策略"
git merge page_tmp -m "合并page" --strategy-option theirs

echo "将新文件添加到暂存区"
git add .

echo "提交更改，注释为“部署”"
git commit -m "部署"

echo "将本地更改推送到远程仓库，并设置 upstream"
git push --set-upstream origin page

if [ $? -eq 0 ]; then
    echo "page 分支 git push 执行成功"
else
    echo "page 分支 git push 执行失败, 重试"
    git push --set-upstream origin page
    if [ $? -eq 0 ]; then
        echo "page 分支 git push 重试成功"
    else
        echo "page 分支 git push 重试失败"
        exit 1
    fi
fi

echo "部署完毕"
git checkout main

echo "删除 page_tmp 分支"
git branch -D page_tmp

exit 0