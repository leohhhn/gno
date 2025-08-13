package raffle

import (
	"math/rand"
	"strings"

	"gno.land/p/demo/ownable"
	"gno.land/p/demo/ufmt"
)

var Ownable = ownable.NewWithAddress("g125em6arxsnj49vx35f0n0z34putv5ty3376fg5")

func PickWinner1(_ realm) string {
	Ownable.AssertOwnedByPrevious()
	winner1 = pickWinner()

	return winner1.ghUsername
}

func PickWinner2(_ realm) string {
	Ownable.AssertOwnedByPrevious()
	winner2 = pickWinner()

	return winner2.ghUsername
}

func UploadCodeHashes(_ realm, delimCodes string) {
	Ownable.AssertOwnedByPrevious()

	tokens := strings.Split(delimCodes, ",")

	if len(tokens) != amtOfCodes {
		panic(ufmt.Sprintf("invalid amount of codes; wanted %d got %d", amtOfCodes, len(tokens)))
	}

	copy(codeHashes, tokens)
}

func UploadRandomness(_ realm, x, y uint64) {
	Ownable.AssertOwnedByPrevious()

	randSource = rand.New(rand.NewPCG(x, y))
}
