check-links:
	-lychee -v --no-progress index.html

local:
	make -j 2 _serve-local-server _open-localhost

_serve-local-server:
	python3 -m http.server 8000

_open-localhost:
	open "http://localhost:8000"