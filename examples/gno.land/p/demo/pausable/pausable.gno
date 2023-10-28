package pausable

type Pausable struct {
	paused bool
}

// New returns a new Pausable struct with non-paused state as default
func New() *Pausable {
	return &Pausable{paused: false}
}

// IsPaused checks if Pausable is paused
func (p *Pausable) IsPaused() bool {
	return p.paused
}

// SetPaused sets the state for the Pausable
func (p *Pausable) SetPaused(state bool) {
	p.paused = state
}
