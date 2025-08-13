package raffle

import (
	"crypto/sha256"
	"encoding/hex"
	"math/rand"
	"std"

	"gno.land/p/demo/ufmt"
)

// EntryData is the main struct that contains all data on raffle entries
type EntryData struct {
	txorigin   std.Address
	caller     std.Realm
	raffleCode string
	codeHash   string
	ghUsername string
}

// Top-level variables are automatically persisted to storage
var (
	partialEntries   []*EntryData        // keeps registered partialEntries
	completeEntries  []*EntryData        // keeps complete registrations: valid code + gh username
	codeHashes       []string            // valid code hashes
	registeredHashes map[string]struct{} // tracks if a code has been registered before
	winner1, winner2 *EntryData          // storing raffle winners
	numOfRegUsers    int
	randSource       *rand.Rand
)

// Nothing to see here, just some constants, move on :)
const (
	codeLength  = 10
	amtOfCodes  = 300
	numOfPrizes = 2
)

// Hello! This is where you register your raffle code!
// Calling RegisterCode is the first step for entering the raffle.
// It allows you to register a specific raffle code and connect your address to it.

// RegisterCode only be called via other code; you should figure out a way to do it.
func RegisterCode(_ realm, code string) string {
	caller := std.PreviousRealm() // save code realm used to call
	origin := std.OriginCaller()  // save deployer of realm

	// Deny non-code entries
	if caller.IsUser() {
		panic("denied; can only be called from within code")
	}

	// Get sha256 of code
	hash := sha256.Sum256([]byte(code))
	hashString := hex.EncodeToString(hash[:])

	// Check if code has already been registered
	if _, ok := registeredHashes[hashString]; ok {
		panic("code already registered: " + code)
	}

	// Check if the gopher has already registered another raffle code
	if originExists(origin) {
		panic("you cannot register more than one code!")
	}

	// Try to find the hash in the official hash list
	var found bool
	for _, ch := range codeHashes {
		if ch == hashString {
			found = true
			break
		}
	}

	if !found {
		panic("specified code is not a valid raffle code: " + code)
	}

	entry := &EntryData{
		txorigin:   origin,
		caller:     caller,
		raffleCode: code,
		codeHash:   hashString,
		ghUsername: "",
	}

	// Save to hash tracker
	registeredHashes[hashString] = struct{}{}

	// Save raffle entry
	partialEntries = append(partialEntries, entry)

	return ufmt.Sprintf("Successfully registered raffle code!\n%s\nRegister your username to complete your raffle entry.", entry.String())
}

// Somewhat similar to Go, init() executes upon deployment of your code.
// Hint: maybe you can use init() in your code to execute RegisterCode() upon deployment via play.gno.land?
func init() {

	partialEntries = make([]*EntryData, 0)
	completeEntries = make([]*EntryData, 0)
	registeredHashes = make(map[string]struct{})
	codeHashes = make([]string, 300)
}

// RegisterUsername registers a GitHub username to an already existing entry
// Hint: you can call this function just like you did with RegisterCode(), or via gno.studio/connect :)
// If you use Connect, make sure you're on the Test7 network, and you've navigated to the correct path!
// If you're chosen as a winner, you'll need to present a logged-in GitHub page matching the username.
func RegisterUsername(_ realm, username string) string {
	if username == "" {
		panic("invalid username: " + username)
	}

	origin := std.OriginCaller()

	for _, entry := range partialEntries {
		if entry.txorigin == origin { // this will check if you're using the same address as when registering the raffle code ;)
			if entry.ghUsername != "" {
				panic("you cannot register your username twice!")
			}

			entry.ghUsername = username
			completeEntries = append(completeEntries, entry)
			numOfRegUsers += 1
			return ufmt.Sprintf("successfully registered %s for address %s", username, entry.txorigin)
		}
	}

	panic("could not find entry for caller address; did you register your raffle code yet?")
}

// Helpers

func (entry *EntryData) String() string {
	return ufmt.Sprintf("Address: %s\nRealm Path: %s\nCode: %s\nHash: %s\nGitHub username: %s\n",
		entry.txorigin.String(),
		entry.caller.PkgPath(),
		entry.raffleCode,
		entry.codeHash,
		entry.ghUsername,
	)
}

func pickWinner() *EntryData {
	if len(completeEntries) == 0 {
		panic("No complete entries yet!")
	}
	if randSource == nil {
		panic("No randomness source yet!")
	}

	r := rand.New(randSource)
	winnerIndex := r.IntN(len(completeEntries))
	winner := completeEntries[winnerIndex]

	// remove winner from entry list
	completeEntries = append(completeEntries[:winnerIndex], completeEntries[winnerIndex+1:]...)

	return winner
}

func CheckHashUpload() int {
	return len(codeHashes)
}

func originExists(origin std.Address) bool {
	for _, e := range partialEntries {
		if e.txorigin == origin {
			return true
		}
	}

	return false
}
