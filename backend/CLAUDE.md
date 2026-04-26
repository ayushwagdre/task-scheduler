# Go Backend Service Template Notes

This service follows the conventions in the provided `CLAUDE.md` template:

- Router: `github.com/julienschmidt/httprouter`
- ORM: `gorm.io/gorm` + `gorm.io/driver/postgres`
- Layers: `routes -> endpoints -> services -> repositories`
- HTTP abstraction: `lib/web` with `web.Serve()` and response envelope
- Config singleton: `config.Get()`

