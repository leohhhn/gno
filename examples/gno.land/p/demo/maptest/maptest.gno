package maptest

import "std"

type MyStruct struct {
	mymap map[std.Address]struct{}
}

func NewStruct() *MyStruct {
	return &MyStruct{
		mymap: make(map[std.Address]struct{}),
	}
}

func (s *MyStruct) AddToMap(addr std.Address) {
	s.mymap[addr] = struct{}{}
}

func (s *MyStruct) Check(address std.Address) bool {
	_, exists := s.mymap[address]
	return exists
}
