# choose-linux-python
choose linux python version

- install script

```
bash <(curl -sSL https://raw.githubusercontent.com/midoks/choose-linux-python/main/install.sh)

curl --insecure -fsSL https://raw.githubusercontent.com/midoks/choose-linux-python/main/install.sh | bash
```

- global

```
curl --insecure -fsSL https://cdn.jsdelivr.net/gh/midoks/choose-linux-python@latest/install.sh | bash
```


### Stargazers over time

[![Stargazers over time](https://starchart.cc/midoks/choose-linux-python.svg)](https://starchart.cc/midoks/choose-linux-python)


### FAQ

- 如果提示 `Command 'curl' not found` 则说明当前未安装 `curl` 软件包

```bash
yum install -y curl || apt-get install -y curl
```

- 如果提示 `Command 'wget' not found` 则说明当前未安装 `wget` 软件包

```bash
yum install -y wget || apt-get install -y wget
```

- 如果提示 `bash: /proc/self/fd/11: No such file or directory`，请切换至 `Root` 用户执行