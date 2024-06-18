package maptest

import (
	"std"

	"gno.land/p/demo/maptest"
)

var s *maptest.MyStruct

func init() {
	s = maptest.NewStruct()
}

func AddToMap(addr std.Address) {
	s.AddToMap(addr)
}

func Check(addr std.Address) bool {
	return s.Check(addr)
}
