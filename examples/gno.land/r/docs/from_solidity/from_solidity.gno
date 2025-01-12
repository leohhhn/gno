package from_solidity

func Render(_ string) string {
	out := "# From Solidity to Gno!\n\n"

	out += `Below is a list of short tutorials that will help you learn about similarities and 
differences between Solidity and Gno.`

	out += `
- [Sending GNOT](/r/docs/from_solidity/sending_gnot) - Learn how to programatically send the gno.land native coin, GNOT.

...
`

	return out
}
