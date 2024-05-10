package coin

import (
	"std"

	"gno.land/p/demo/ufmt"
)

func Coin() string {
	// We can make a new coin instance, 1000000 coins of denomination ugnot, equal to 1 GNOT
	var coinA std.Coin = std.Coin{"ugnot", 1000000}

	// You can get a string representaton of a coin with the `String()` method
	stringedCoin := coinA.String()

	// We can make another instance of ugnot coins, but with a different amount
	var coinB std.Coin = std.Coin{"ugnot", 100}

	// We can perform simple checks on coin instances to compare them
	if coinA.IsGTE(coinB) {
		return ufmt.Sprintf("Coin A (%s) is greater than or equal than Coin B (%s)!", coinA.String(), coinB.String())
	}
	return ufmt.Sprintf("Coin B (%s) is greater than or equal than Coin A (%s)!", coinB.String(), coinA.String())
}

func Coins() string {
	// Get coins sent with transaction
	return ufmt.Sprintf(std.GetOrigSend().String())
}
