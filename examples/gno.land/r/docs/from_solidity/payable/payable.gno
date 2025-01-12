package payable

func Render(_ string) string {
	out := "# Payable\n\n"
	out += `All functions in Gno are payable by default. If a realm does not 
have any functions defined, the realm's address can be derived from its pkgpath 
and MsgSend can be used to directly transfer coins to the address.`
	return out
}
