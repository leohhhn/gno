package main

import (
	"gno.land/r/leon/home"
)

func main() {
	home.UpdateMagic(func() string {
		return "Magical!!"
	})
}
