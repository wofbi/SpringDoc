echo "切换到主分支"
git checkout main

echo "添加所有文件"
git add .

echo "提交更改，注释为“部署”"
git commit -m "部署"

echo "从远程仓库中拉取最新版本的主分支"
git pull origin main

if %errorlevel% == 0 (
    echo "main 分支 git pull 执行成功"
) else (
    echo "main 分支 git pull 执行失败"
    goto end
)

echo "将本地更改推送到远程仓库"
git push

echo "删除本地名为 page_tmp 的分支"
for /F "delims=" %%i in ('git branch --list page_tmp') do set branch_exists=%%i
if defined branch_exists (
    git branch -D page_tmp
)

echo "创建新分支 page_tmp，将其基于主分支"
git branch page_tmp main

echo "切换到 page_tmp 分支"
git checkout page_tmp

echo "在当前目录中安装依赖包"
call yarn install 

if %errorlevel% == 0 (
    echo "yarn install 执行成功"
) else (
    echo "yarn install 执行失败"
    goto end
)

echo "运行 yarn 脚本 build"
call yarn build

if %errorlevel% == 0 (
    echo "yarn run build 执行成功"
) else (
    echo "yarn run build 执行失败"
    goto end
)

echo "将 docs/.vitepress/dist 目录下的所有文件复制到当前目录"
xcopy /y /c /h /r /s docs\.vitepress\dist\* .\

echo "将新文件添加到暂存区"
git add .

echo "提交更改，注释为“部署”"
git commit -m "部署"

echo "切换到 page 分支"
git checkout page

echo "从远程仓库中拉取最新版本的 page 分支"
git pull origin page

if %errorlevel% == 0 (
    echo "page 分支 git pull 执行成功"
) else (
    echo "page 分支 git pull 执行失败"
    goto end
)

echo "将 page_tmp 分支合并到 page 分支，使用 theirs 策略"
git merge page_tmp -m "合并page" --strategy-option theirs

echo "将新文件添加到暂存区"
git add .

echo "提交更改，注释为“部署”"
git commit -m "部署"

echo "将本地更改推送到远程仓库，并设置 upstream"
git push --set-upstream origin page

if %errorlevel% == 0 (
    echo "page 分支 git push 执行成功"
) else (
    echo "page 分支 git push 执行失败, 重试"
    git push --set-upstream origin page

    if %errorlevel% == 0 (
        echo "page 分支 git push 执行成功"
    ) else (
        echo "page 分支 git push 执行失败, 请手动执行以下命令"
        echo "git push --set-upstream origin page"
        echo "checkout main"
        echo "git branch -D page_tmp"
        goto end
    )
)

echo "部署完毕"
git checkout main

echo "删除 page_tmp 分支"
git branch -D page_tmp
