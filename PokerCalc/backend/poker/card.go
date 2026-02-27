package poker

import "fmt"

type Card struct {
	Suit byte
	Rank int
}

func ParseCard(s string) (Card, error) {
	if len(s) != 2 {
		return Card{}, fmt.Errorf("invalid card length: %s", s)
	}
	suit := s[0]
	switch suit {
	case 'H', 'S', 'C', 'D':
	default:
		return Card{}, fmt.Errorf("invalid suit in %s", s)
	}

	rank := 0
	switch s[1] {
	case '2', '3', '4', '5', '6', '7', '8', '9':
		rank = int(s[1] - '0')
	case 'T':
		rank = 10
	case 'J':
		rank = 11
	case 'Q':
		rank = 12
	case 'K':
		rank = 13
	case 'A':
		rank = 14
	default:
		return Card{}, fmt.Errorf("invalid rank %c in %s", s[1], s)
	}

	return Card{Suit: suit, Rank: rank}, nil
}

func (c Card) String() string {
	r := ""
	switch c.Rank {
	case 10:
		r = "T"
	case 11:
		r = "J"
	case 12:
		r = "Q"
	case 13:
		r = "K"
	case 14:
		r = "A"
	default:
		r = fmt.Sprintf("%d", c.Rank)
	}
	return string([]byte{c.Suit}) + r
}

func ParseCards(strs []string) ([]Card, error) {
	var cards []Card
	for _, s := range strs {
		c, err := ParseCard(s)
		if err != nil {
			return nil, err
		}
		cards = append(cards, c)
	}
	return cards, nil
}
