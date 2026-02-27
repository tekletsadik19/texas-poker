package poker

import (
	"sort"
)

type HandRank int

const (
	HighCard HandRank = iota
	OnePair
	TwoPair
	ThreeOfAKind
	Straight
	Flush
	FullHouse
	FourOfAKind
	StraightFlush
	RoyalFlush
)

func (r HandRank) String() string {
	switch r {
	case HighCard:
		return "High Card"
	case OnePair:
		return "One Pair"
	case TwoPair:
		return "Two Pair"
	case ThreeOfAKind:
		return "Three of a Kind"
	case Straight:
		return "Straight"
	case Flush:
		return "Flush"
	case FullHouse:
		return "Full House"
	case FourOfAKind:
		return "Four of a Kind"
	case StraightFlush:
		return "Straight Flush"
	case RoyalFlush:
		return "Royal Flush"
	default:
		return "Unknown"
	}
}

type HandEval struct {
	Rank      HandRank
	Score     int
	Cards     []Card
}

func Evaluate7(cards []Card) HandEval {
	if len(cards) < 5 {
		return Evaluate5(cards)
	}
	var best HandEval

	var combs func(start int, current []Card)
	combs = func(start int, current []Card) {
		if len(current) == 5 {
			eval := Evaluate5(current)
			if eval.Score > best.Score {
				best = eval
			}
			return
		}
		for i := start; i < len(cards); i++ {
			cc := append([]Card(nil), current...)
			cc = append(cc, cards[i])
			combs(i+1, cc)
		}
	}
	combs(0, nil)
	return best
}

func Evaluate5(cards []Card) HandEval {
	sc := make([]Card, len(cards))
	copy(sc, cards)
	sort.Slice(sc, func(i, j int) bool {
		return sc[i].Rank > sc[j].Rank
	})

	isFlush := true
	for i := 1; i < len(sc); i++ {
		if sc[i].Suit != sc[0].Suit {
			isFlush = false
			break
		}
	}

	isStraight := false
	straightHigh := 0
	if len(sc) == 5 {
		if sc[0].Rank == sc[1].Rank+1 && sc[1].Rank == sc[2].Rank+1 && sc[2].Rank == sc[3].Rank+1 && sc[3].Rank == sc[4].Rank+1 {
			isStraight = true
			straightHigh = sc[0].Rank
		} else if sc[0].Rank == 14 && sc[1].Rank == 5 && sc[2].Rank == 4 && sc[3].Rank == 3 && sc[4].Rank == 2 {
			isStraight = true
			straightHigh = 5
			sc = []Card{sc[1], sc[2], sc[3], sc[4], sc[0]}
		}
	}

	counts := make(map[int]int)
	for _, c := range sc {
		counts[c.Rank]++
	}

	var pairs, trips, quads []int
	for rank, count := range counts {
		if count == 4 {
			quads = append(quads, rank)
		} else if count == 3 {
			trips = append(trips, rank)
		} else if count == 2 {
			pairs = append(pairs, rank)
		}
	}
	sort.Sort(sort.Reverse(sort.IntSlice(pairs)))
	sort.Sort(sort.Reverse(sort.IntSlice(trips)))

	var rank HandRank
	score := 0

	makeScore := func(r HandRank, tieBreakers ...int) int {
		s := int(r) << 20
		shift := 16
		for _, tb := range tieBreakers {
			s |= (tb & 0xF) << shift
			shift -= 4
		}
		return s
	}

	if isStraight && isFlush {
		if straightHigh == 14 {
			rank = RoyalFlush
			score = makeScore(RoyalFlush)
		} else {
			rank = StraightFlush
			score = makeScore(StraightFlush, straightHigh)
		}
	} else if len(quads) > 0 {
		rank = FourOfAKind
		kicker := 0
		if len(sc) == 5 {
			kicker = sc[0].Rank
			if kicker == quads[0] {
				kicker = sc[4].Rank
			}
		}
		score = makeScore(FourOfAKind, quads[0], kicker)
		
		var newSC []Card
		for _, c := range sc { if c.Rank == quads[0] { newSC = append(newSC, c) } }
		for _, c := range sc { if c.Rank != quads[0] { newSC = append(newSC, c) } }
		sc = newSC
	} else if len(trips) > 0 && len(pairs) > 0 {
		rank = FullHouse
		score = makeScore(FullHouse, trips[0], pairs[0])
		
		var newSC []Card
		for _, c := range sc { if c.Rank == trips[0] { newSC = append(newSC, c) } }
		for _, c := range sc { if c.Rank == pairs[0] { newSC = append(newSC, c) } }
		sc = newSC
	} else if isFlush {
		rank = Flush
		if len(sc) == 5 {
			score = makeScore(Flush, sc[0].Rank, sc[1].Rank, sc[2].Rank, sc[3].Rank, sc[4].Rank)
		} else {
			score = makeScore(Flush)
		}
	} else if isStraight {
		rank = Straight
		score = makeScore(Straight, straightHigh)
	} else if len(trips) > 0 {
		rank = ThreeOfAKind
		k1, k2 := 0, 0
		var newSC []Card
		for _, c := range sc { if c.Rank == trips[0] { newSC = append(newSC, c) } }
		for _, c := range sc { 
			if c.Rank != trips[0] {
				newSC = append(newSC, c)
				if k1 == 0 { k1 = c.Rank } else { k2 = c.Rank }
			}
		}
		sc = newSC
		score = makeScore(ThreeOfAKind, trips[0], k1, k2)
	} else if len(pairs) >= 2 {
		rank = TwoPair
		k := 0
		var newSC []Card
		for _, c := range sc { if c.Rank == pairs[0] { newSC = append(newSC, c) } }
		for _, c := range sc { if c.Rank == pairs[1] { newSC = append(newSC, c) } }
		for _, c := range sc { 
			if c.Rank != pairs[0] && c.Rank != pairs[1] {
				newSC = append(newSC, c)
				k = c.Rank
			}
		}
		sc = newSC
		score = makeScore(TwoPair, pairs[0], pairs[1], k)
	} else if len(pairs) == 1 {
		rank = OnePair
		var k []int
		var newSC []Card
		for _, c := range sc { if c.Rank == pairs[0] { newSC = append(newSC, c) } }
		for _, c := range sc { 
			if c.Rank != pairs[0] {
				newSC = append(newSC, c)
				k = append(k, c.Rank)
			}
		}
		sc = newSC
		if len(k) >= 3 {
			score = makeScore(OnePair, pairs[0], k[0], k[1], k[2])
		} else {
			score = makeScore(OnePair, pairs[0])
		}
	} else {
		rank = HighCard
		if len(sc) == 5 {
			score = makeScore(HighCard, sc[0].Rank, sc[1].Rank, sc[2].Rank, sc[3].Rank, sc[4].Rank)
		} else {
			score = makeScore(HighCard)
		}
	}

	return HandEval{
		Rank:  rank,
		Score: score,
		Cards: sc,
	}
}
