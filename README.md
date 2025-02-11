# intranet-proxy-builder

- what is this repository for?

This repository is a script to build a proxy server for the intranet. It is based on the [pages](https://zhizhengfu.github.io/tech/proxy.html) I wrote on my website.

If you donnot want to read the pages, you can just run the script. It will build a proxy server for you.

- where to run the script?

a server which can both connect to the internet and the intranet ---- often your laptop or a server in the intranet.

- system requirements

macOS or Linux! If you are using Windows, you can use WSL2.

- how to run?

```bash
git clone https://github.com/ZhizhengFu/intranet-proxy-builder.git
cd intranet-proxy-builder
chmod +x script.sh
bash script.sh
```

- what you will download in the script?

nginx \ openssl \ pcre \ zlib \ chobits/ngx_http_proxy_connect_module from github repository

- On the intraent side, what you need to do?

Just open the [pages](https://zhizhengfu.github.io/tech/proxy.html) for more details. By the way, the script defaultly exposes 8000 port for the intranet side.
