package data

import (
	"database/sql"
	"errors"
)

var (
	ErrRecordNotFound = errors.New("record not found")
	ErrEditConflict   = errors.New("edit conflict")
)

type Models struct {
	Permissions PermissionModel
	Movies      MovieModel
	Users       UserModel
	Tokens      TokenModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		Permissions: PermissionModel{DB: db},
		Movies:      MovieModel{DB: db},
		Users:       UserModel{DB: db},
		Tokens:      TokenModel{DB: db},
	}
}
