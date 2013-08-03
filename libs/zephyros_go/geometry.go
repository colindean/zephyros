package zephyros_go

type screen float64

type Rect struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
	W float64 `json:"w"`
	H float64 `json:"h"`
}

type Size struct {
	W float64 `json:"w"`
	H float64 `json:"h"`
}

type TopLeft struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}
