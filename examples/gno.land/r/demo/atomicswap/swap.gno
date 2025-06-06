package atomicswap

import (
	"crypto/sha256"
	"encoding/hex"
	"std"
	"time"

	"gno.land/p/demo/ufmt"
)

// Swap represents an atomic swap contract.
type Swap struct {
	sender    std.Address
	recipient std.Address
	hashlock  string
	timelock  time.Time
	claimed   bool
	refunded  bool
	amountStr string
	sendFn    func(cur realm, to std.Address)
}

func newSwap(
	sender std.Address,
	recipient std.Address,
	hashlock string,
	timelock time.Time,
	amountStr string,
	sendFn func(realm, std.Address),
) *Swap {
	require(time.Now().Before(timelock), "timelock must be in the future")
	require(hashlock != "", "hashlock must not be empty")
	return &Swap{
		recipient: recipient,
		sender:    sender,
		hashlock:  hashlock,
		timelock:  timelock,
		claimed:   false,
		refunded:  false,
		sendFn:    sendFn,
		amountStr: amountStr,
	}
}

// Claim allows the recipient to claim the funds if they provide the correct preimage.
func (s *Swap) Claim(preimage string) {
	require(!s.claimed, "already claimed")
	require(!s.refunded, "already refunded")
	require(std.PreviousRealm().Address() == s.recipient, "unauthorized")

	hashlock := sha256.Sum256([]byte(preimage))
	hashlockHex := hex.EncodeToString(hashlock[:])
	require(hashlockHex == s.hashlock, "invalid preimage")

	s.claimed = true
	s.sendFn(cross, s.recipient)
}

// Refund allows the sender to refund the funds after the timelock has expired.
func (s *Swap) Refund() {
	require(!s.claimed, "already claimed")
	require(!s.refunded, "already refunded")
	require(std.PreviousRealm().Address() == s.sender, "unauthorized")
	require(time.Now().After(s.timelock), "timelock not expired")

	s.refunded = true
	s.sendFn(cross, s.sender)
}

func (s Swap) Status() string {
	switch {
	case s.refunded:
		return "refunded"
	case s.claimed:
		return "claimed"
	case s.TimeRemaining() < 0:
		return "expired"
	default:
		return "active"
	}
}

func (s Swap) TimeRemaining() time.Duration {
	remaining := time.Until(s.timelock)
	if remaining < 0 {
		return 0
	}
	return remaining
}

// String returns the current state of the swap.
func (s Swap) String() string {
	return ufmt.Sprintf(
		"- status: %s\n- sender: %s\n- recipient: %s\n- amount: %s\n- hashlock: %s\n- timelock: %s\n- remaining: %s",
		s.Status(), s.sender, s.recipient, s.amountStr, s.hashlock, s.timelock.Format(time.RFC3339), s.TimeRemaining().String(),
	)
}
