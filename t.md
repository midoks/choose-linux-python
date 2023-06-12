

tar -xvJf Python-3.10.10.tar.xz


/tmp/Python-3.10.10/configure --prefix=/usr/local/python3.10.10 \
		--enable-optimizations \
		--with-ssl \
		--with-openssl-rpath=auto