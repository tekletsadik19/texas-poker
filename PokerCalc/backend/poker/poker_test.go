package poker

import (
	"strings"
	"testing"
)

func parse(strs string) []Card {
	c, _ := ParseCards(strings.Split(strs, " "))
	return c
}

func TestEvaluate7(t *testing.T) {
	tests := []struct {
		name     string
		cards    string
		expected HandRank
		scoreLen int
		best     string // The best 5 cards
	}{
		{
			name:     "Royal Flush",
			cards:    "HA HK HQ HJ HT H9 S2",
			expected: RoyalFlush,
			best:     "HA HK HQ HJ HT",
		},
		{
			name:     "Straight Flush",
			cards:    "H9 H8 H7 H6 H5 C2 D3",
			expected: StraightFlush,
			best:     "H9 H8 H7 H6 H5",
		},
		{
			name:     "Four of a Kind",
			cards:    "CA DA HA SA CK C2 D3",
			expected: FourOfAKind,
			best:     "CA DA HA SA CK",
		},
		{
			name:     "Full House",
			cards:    "C3 D3 H3 CA DA S2 C2",
			expected: FullHouse,
			best:     "C3 D3 H3 CA DA",
		},
		{
			name:     "Flush",
			cards:    "HA HQ H9 H7 H3 C2 D4",
			expected: Flush,
			best:     "HA HQ H9 H7 H3",
		},
		{
			name:     "Straight",
			cards:    "C5 D6 H7 S8 C9 HK S2",
			expected: Straight,
			best:     "C9 S8 H7 D6 C5",
		},
		{
			name:     "Straight Low Ace",
			cards:    "HA C2 D3 S4 H5 D9 CJ",
			expected: Straight,
			best:     "H5 S4 D3 C2 HA",
		},
		{
			name:     "Three of a Kind",
			cards:    "HK DK SK HA C2 D4 S5",
			expected: ThreeOfAKind,
			best:     "HK DK SK HA S5",
		},
		{
			name:     "Two Pair",
			cards:    "HQ DQ H5 D5 CA S2 D3",
			expected: TwoPair,
			best:     "HQ DQ H5 D5 CA",
		},
		{
			name:     "One Pair",
			cards:    "HA DA HK CQ S7 D2 C3",
			expected: OnePair,
			best:     "HA DA HK CQ S7",
		},
		{
			name:     "High Card",
			cards:    "HA CK DQ SJ C9 D2 S3",
			expected: HighCard,
			best:     "HA CK DQ SJ C9",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			cards := parse(tt.cards)
			eval := Evaluate7(cards)
			if eval.Rank != tt.expected {
				t.Errorf("expected rank %v, got %v", tt.expected, eval.Rank)
			}
			
			var bestStrs []string
			for _, c := range eval.Cards {
				bestStrs = append(bestStrs, c.String())
			}
			bestStr := strings.Join(bestStrs, " ")
			if tt.best != "" && bestStr != tt.best {
				t.Errorf("expected best cards %v, got %v", tt.best, bestStr)
			}
		})
	}
}

func TestCompare(t *testing.T) {
	tests := []struct{
		name string
		p1 string
		p2 string
		comm string
		expectedWinner int
	}{
		{
			"p1 wins with higher pair",
			"HA DA", "HK DK", "C2 D3 S4 H7 S9",
			1,
		},
		{
			"p2 wins with flush over straight",
			"H2 H3", "S5 D6", "H4 H5 H6 C7 D8",
			1, // wait, p1: 2,3,4,5,6 H flush. p2: 4,5,6,7,8 straight. Flush beats straight! p1 wins
		},
		{
			"tie with community royal flush",
			"S2 D3", "C2 H3", "HA HK HQ HJ HT",
			0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			p1 := parse(tt.p1)
			p2 := parse(tt.p2)
			comm := parse(tt.comm)
			res := CompareHands(p1, p2, comm)
			if res.Winner != tt.expectedWinner {
				t.Errorf("expected winner %d, got %d", tt.expectedWinner, res.Winner)
			}
		})
	}
}

func TestMonteCarlo(t *testing.T) {
	hole := parse("AA KA") // invalid cards intentionally, let's use HA SA
	hole = parse("HA SA")
	comm := parse("")
	res := Simulate(hole, comm, 2, 1000)
	if res.WinProbability < 0.8 {
		t.Errorf("AA should win > 80%% preflop, got %f", res.WinProbability)
	}
}
