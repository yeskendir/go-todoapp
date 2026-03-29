package domain

type NullableString struct {
	Value *string
	Set   bool
}

// a generic for accepting any type (incl. interface: only types that have the same methods as in interface definition can be used) as a value-field and
// creating common multi-type methods (a variable created in a form, e. g., var := Nullable[<type>]{})
type Nullable[T any] struct {
	Value *T
	Set   bool
}
