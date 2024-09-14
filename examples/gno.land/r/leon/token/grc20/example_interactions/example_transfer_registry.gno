package main

import (
	reg "gno.land/r/leon/token/registry"
)

func main() {
	err := reg.Tokens[0].Transfer("g13awn2575t8s2vf3svlprc4dg0e9z5wchejdxk8", 10_000*1_000_000)
	if err != nil {
		panic(err)
	}
}
