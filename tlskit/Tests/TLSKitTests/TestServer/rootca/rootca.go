package rootca

import (
	"embed"
)

//go:embed *.pem *.sig *.json
var Files embed.FS
