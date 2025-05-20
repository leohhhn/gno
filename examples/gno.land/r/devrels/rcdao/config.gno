package rcdao

import (
	pc "gno.land/p/nt/commondao"
	"gno.land/r/nt/commondao"
)

var DAO *pc.CommonDAO

func init() {
	DAO = commondao.New("Regional Community DAO")
}

func Render(_ string) string {
	return DAO.Render("")
}
