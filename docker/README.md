## 使用
- 安装默认版本（docker=19.03.5, docker-compose=1.25.0）
```
./install-docker.sh
```
- 安装指定版本
```
./install-docker.sh [docer-version] [docker-compose-version]
示例
./install-docker.sh 19.03.5 1.25.0
```
## 说明
- 支持的Linux发行版： Ubuntu >= 16.04 或者 CentOS >= 7
- 支持的Docker版本： >= 18.09.0
- docker-compose支持本地安装和在线安装,优先执行本地安装
  - 本地安装包须和脚本执行目录保持一致
  - 本地安装包命名规则为：`docker-compose-${DOCKER_COMPOSE_VERSION}-$(uname -s)-$(uname -m)`，示例如下：
    ```
    docker-compose-1.25.0-Linux-x86_64
    ```
- command-completion支持本地安装和在线安装,优先执行本地安装
  - 本地安装包须和脚本执行目录保持一致
  - 本地安装包命名规则为：`command-completion-${DOCKER_COMPOSE_VERSION}-$(uname -s)-$(uname -m)`，示例如下：
    ```
    command-completion-1.25.0-Linux-x86_64
    ```
## 安装之后
- 非root用户免sudo配置
    ```
    sudo usermod -aG docker $your-user
    ```
    退出并重新登录使其生效。
 