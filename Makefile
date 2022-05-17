.PHONY: build

build:
	python setup.py build_ext --inplace

install:
	python setup.py install

talib/_func.pxi: tools/generate_func.py
	python tools/generate_func.py > talib/_func.pxi

talib/_stream.pxi: tools/generate_stream.py
	python tools/generate_stream.py > talib/_stream.pxi

generate: talib/_func.pxi talib/_stream.pxi

cython:
	cython --directive emit_code_comments=False talib/_ta_lib.pyx

clean:
	rm -rf build talib/_ta_lib.so talib/*.pyc

perf:
	python tools/perf_talib.py

test: build
	LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH} nosetests

sdist:
	python setup.py sdist --formats=gztar,zip

download:
	curl -L -O https://github.com/Yvictor/ta-lib/releases/download/TA_Lib-0.4.17/ta-lib-0.4.0-src.tar.gz
	tar -xzf ta-lib-0.4.0-src.tar.gz

manylinux-wheel:
	for PYBIN in $(wildcard /opt/python/*/bin);	\
	do	\
		$$PYBIN/pip install -r requirements.txt;	\
		$$PYBIN/pip wheel ./ -w wheelhouse/;	\
		rm -rf build;	\
	done

repair-manylinux-wheel:
	for whl in $(wildcard wheelhouse/*.whl);	\
	do	\
		auditwheel repair $$whl -w wheelhouse/;	\
	done

install-test:
	rm -rf talib
	for PYBIN in $(wildcard /opt/python/*/bin);	\
	do	\
		$$PYBIN/pip install talib-bin --no-index -f wheelhouse;	\
	done

upload-pypi-server:
	twine upload wheelhouse/talib_bin*.whl